module SpreeCmCommissioner
  module LineItemDecorator
    def self.prepended(base)
      include_modules(base)

      base.belongs_to :accepter, class_name: 'Spree::User', optional: true
      base.belongs_to :rejecter, class_name: 'Spree::User', optional: true

      base.has_one :google_wallet, class_name: 'SpreeCmCommissioner::GoogleWallet', through: :product

      base.has_many :taxons, class_name: 'Spree::Taxon', through: :product
      base.has_many :guests, class_name: 'SpreeCmCommissioner::Guest', dependent: :destroy
      base.has_many :pending_guests, pending_guests_query, class_name: 'SpreeCmCommissioner::Guest', dependent: :destroy
      base.has_many :product_completion_steps, class_name: 'SpreeCmCommissioner::ProductCompletionStep', through: :product
      base.has_many :taxon_star_ratings, class_name: 'SpreeCmCommissioner::TaxonStarRating', through: :product

      base.before_save :update_vendor_id
      base.before_create :add_due_date, if: :subscription?

      base.validate :ensure_not_exceed_max_quantity_per_order, if: -> { variant&.max_quantity_per_order.present? }

      base.whitelisted_ransackable_associations |= %w[guests]
      base.whitelisted_ransackable_attributes |= %w[number to_date from_date]

      base.delegate :delivery_required?, :permanent_stock?,
                    to: :variant

      base.accepts_nested_attributes_for :guests, allow_destroy: true

      def base.json_api_columns
        json_api_columns = column_names.reject { |c| c.match(/_id$|id|preferences|(.*)password|(.*)token|(.*)api_key/) }
        json_api_columns << :options_text
        json_api_columns << :vendor_id
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
      base.include SpreeCmCommissioner::ProductDelegation
      base.include SpreeCmCommissioner::KycBitwise
    end

    def self.pending_guests_query
      lambda {
        left_outer_joins(:id_card)
          .where(upload_later: true, id_card: { front_image: nil })
      }
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
      ecommerce? && guests.any? && product.allow_self_check_in?
    end

    def amount_per_guest
      amount / quantity
    end

    def commission_rate
      product.commission_rate || vendor&.commission_rate || 0
    end

    def commission_amount
      pre_tax_amount * commission_rate / 100.0
    end

    def pre_commission_amount
      [0, pre_tax_amount - commission_amount].max
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
      SpreeCmCommissioner::Stock::LineItemAvailabilityChecker.new(self).can_supply?(quantity)
    end

    def month
      from_date.day < 15 ? from_date.strftime('%B %Y') : from_date.next_month.strftime('%B %Y')
    end

    private

    def ensure_not_exceed_max_quantity_per_order
      errors.add(:quantity, 'exceeded_max_quantity_per_order') if quantity > variant.max_quantity_per_order
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

      return from_date + variant.month.month + day.days if post_paid?

      from_date + day.days
    end
  end
end

unless Spree::LineItem.included_modules.include?(SpreeCmCommissioner::LineItemDecorator)
  Spree::LineItem.prepend(SpreeCmCommissioner::LineItemDecorator)
end
