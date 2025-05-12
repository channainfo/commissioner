module SpreeCmCommissioner
  module LineItemDecorator
    def self.prepended(base) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      include_modules(base)

      base.belongs_to :accepter, class_name: 'Spree::User', optional: true
      base.belongs_to :rejecter, class_name: 'Spree::User', optional: true

      base.has_one :google_wallet, class_name: 'SpreeCmCommissioner::GoogleWallet', through: :product

      base.has_many :option_types, through: :product

      base.has_many :inventory_items, lambda { |line_item|
        where(inventory_date: nil).or(where(inventory_date: line_item.date_range))
      }, through: :variant

      base.has_many :taxons, class_name: 'Spree::Taxon', through: :product
      base.has_many :guests, class_name: 'SpreeCmCommissioner::Guest', dependent: :destroy
      base.has_many :pending_guests, pending_guests_query, class_name: 'SpreeCmCommissioner::Guest', dependent: :destroy
      base.has_many :product_completion_steps, class_name: 'SpreeCmCommissioner::ProductCompletionStep', through: :product
      base.has_many :line_item_seats, class_name: 'SpreeCmCommissioner::LineItemSeat', dependent: :destroy

      base.before_save :update_vendor_id
      base.before_save :update_quantity, if: :transit?

      base.validate :validate_seats_reservation, if: :transit?

      base.before_create :add_due_date, if: :subscription?
      base.before_save -> { self.product_type = variant.product_type }, if: -> { product_type.nil? }

      base.validate :ensure_not_exceed_max_quantity_per_order, if: -> { variant&.max_quantity_per_order.present? }

      base.whitelisted_ransackable_associations |= %w[guests order]
      base.whitelisted_ransackable_attributes |= %w[number to_date from_date vendor_id]

      base.delegate :delivery_required?, :high_demand,
                    to: :variant

      base.accepts_nested_attributes_for :guests, allow_destroy: true
      base.accepts_nested_attributes_for :line_item_seats, allow_destroy: true

      def base.json_api_columns
        json_api_columns = column_names.reject { |c| c.match(/_id$|id|preferences|(.*)password|(.*)token|(.*)api_key/) }
        json_api_columns << :options_text
        json_api_columns << :vendor_id
      end

      def discontinue_on
        variant.discontinue_on || product.discontinue_on
      end

      def base.search_by_qr_data!(data)
        matches = data.match(/(R\d+)-([A-Za-z0-9_\-]+)-(L\d+)/)&.captures

        raise ActiveRecord::RecordNotFound, "Couldn't find Spree::LineItem with QR data: #{data}" unless matches

        order_number, order_token, line_item_id = matches
        line_item_id = line_item_id.delete('L').to_i

        Spree::LineItem.joins(:order)
                       .find_by(id: line_item_id, spree_orders: { number: order_number, token: order_token })
      end
    end

    def self.include_modules(base)
      base.include Spree::Core::NumberGenerator.new(prefix: 'L')
      base.include SpreeCmCommissioner::LineItemDurationable
      base.include SpreeCmCommissioner::LineItemsFilterScope
      base.include SpreeCmCommissioner::LineItemGuestsConcern
      base.include SpreeCmCommissioner::ProductType
      base.include SpreeCmCommissioner::ProductDelegation
      base.include SpreeCmCommissioner::KycBitwise
    end

    def self.pending_guests_query
      lambda {
        left_outer_joins(:id_card)
          .where(upload_later: true, id_card: { front_image: nil })
      }
    end

    def reservation?
      date_present? && !subscription?
    end

    # date_unit could be number of nights, or days or hours depending on usecases
    # For example:
    # - accomodation uses number of nights.
    # - appointment uses number of hours, etc.
    #
    # override
    def amount
      base_price = price * quantity

      if permanent_stock? && date_unit.present?
        base_price * date_unit
      else
        base_price
      end
    end

    def allowed_self_check_in?
      allow_self_check_in?
    end

    def required_self_check_in_location?
      required_self_check_in_location
    end

    def amount_per_guest
      amount / quantity
    end

    def commission_rate
      product.commission_rate || vendor&.commission_rate || 0
    end

    def accepted?
      accepted_at.present?
    end

    def rejected?
      rejected_at.present?
    end

    def accepted_by(user)
      return if accepted_at.present? && accepter_id.present?

      update(
        accepted_at: Time.current,
        accepter: user
      )
    end

    def rejected_by(user)
      return if rejected_at.present? && rejecter_id.present?

      update(
        rejected_at: Time.current,
        rejecter: user
      )
    end

    def generate_svg_qr
      qrcode = RQRCode::QRCode.new(qr_data)
      qrcode.as_svg(
        color: '000',
        shape_rendering: 'crispEdges',
        module_size: 5,
        standalone: true,
        use_path: true,
        viewbox: '0 0 20 10'
      )
    end

    def generate_png_qr(size = 120)
      qrcode = RQRCode::QRCode.new(qr_data)
      qrcode.as_png(
        bit_depth: 1,
        border_modules: 1,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: 'black',
        file: nil,
        fill: 'white',
        module_px_size: 4,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: size
      )
    end

    def qr_data
      return nil if order.nil?

      "#{order.number}-#{order.token}-L#{id}"
    end

    def completion_steps
      @completion_steps ||= product_completion_steps.map do |completion_step|
        completion_step.construct_hash(line_item: self)
      end
    end

    # override
    def sufficient_stock?
      return transit_sufficient_stock? if transit?

      SpreeCmCommissioner::Stock::LineItemAvailabilityChecker.new(self).can_supply?(quantity)
    end

    def month
      to_date.strftime('%B %Y')
    end

    def jwt_token
      payload = { order_number: order.number, line_item_id: id }
      SpreeCmCommissioner::OrderJwtToken.encode(payload, order.token)
    end

    private

    def ensure_not_exceed_max_quantity_per_order
      errors.add(:quantity, 'exceeded_max_quantity_per_order') if quantity > variant.max_quantity_per_order
    end

    def transit_sufficient_stock?
      return selected_seats_available? if reservation_trip.allow_seat_selection

      seat_quantity_available?(reservation_trip)
    end

    def update_quantity
      return if line_item_seats.blank?

      self.quantity = line_item_seats.size
    end

    def update_vendor_id
      self.vendor_id = variant.vendor_id
    end

    def subscription?
      order.subscription.present?
    end

    def add_due_date
      self.due_date = due_days
    end

    def post_paid?
      order.subscription.variant.post_paid?
    end

    def due_days
      variant = order.subscription.variant
      day = variant.due_date

      from_date + variant.month.month + day.days
    end

    def validate_seats_reservation
      return if reservation_trip.blank?

      if reservation_trip.allow_seat_selection && !selected_seats_available?
        errors.add(:base, :some_seats_are_booked, message: 'Some seats are already booked')
      elsif !reservation_trip.allow_seat_selection && !seat_quantity_available?(reservation_trip)
        errors.add(:quantity, :exceeded_available_quantity, message: 'exceeded available quantity')
      end
    end

    def selected_seats_available?
      selected_seat_ids = line_item_seats.map(&:seat_id)
      !selected_seat_ids_occupied?(selected_seat_ids)
    end

    def seat_quantity_available?(trip)
      booked_quantity = Spree::LineItem.joins(:order)
                                       .where(variant_id: variant_id, date: date, spree_orders: { state: 'complete' })
                                       .where.not(spree_line_items: { id: id })
                                       .sum(:quantity)
      remaining_quantity = trip.vehicle.number_of_seats - booked_quantity
      remaining_quantity >= quantity
    end

    def reservation_trip
      return @trip if defined? @trip

      route = Spree::Variant.find_by(id: variant_id).product
      @trip = route.trip
    end

    def selected_seat_ids_occupied?(selected_seat_ids)
      # check to see if there are any selected_ids exist in the line_item_seats and belongs to completed order
      SpreeCmCommissioner::LineItemSeat.joins(line_item: :order)
                                       .where(seat_id: selected_seat_ids, date: date, variant_id: variant_id, spree_orders: { state: 'complete',
                                                                                                                              canceled_at: nil
}
                                       )
                                       .present?
    end
  end
end

unless Spree::LineItem.included_modules.include?(SpreeCmCommissioner::LineItemDecorator)
  Spree::LineItem.prepend(SpreeCmCommissioner::LineItemDecorator)
end
