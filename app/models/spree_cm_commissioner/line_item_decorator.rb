module SpreeCmCommissioner
  module LineItemDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::LineItemDurationable
      base.delegate :need_confirmation, to: :product
      base.belongs_to :accepted_by, class_name: 'Spree::User', optional: true
      base.belongs_to :rejected_by, class_name: 'Spree::User', optional: true
      base.has_many :line_item_seats, class_name: 'SpreeCmCommissioner::LineItemSeat', dependent: :destroy

      base.accepts_nested_attributes_for :line_item_seats, allow_destroy: true

      base.before_save :update_vendor_id
      base.before_save :update_quantity, if: :transit?

      base.validate :validate_seats_reservation, if: :transit?

      base.delegate :product_type, :accommodation?, :service?, :ecommerce?, to: :product
      base.before_create :add_due_date, if: :subscription?

      base.whitelisted_ransackable_attributes |= %w[to_date from_date]
    end

    delegate :transit?, to: :variant

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

      if reservation?
        base_price * date_unit
      else
        base_price
      end
    end

    # override
    def sufficient_stock?
      return super unless variant.product.product_type == 'transit'

      transit_sufficient_stock?
    end

    private

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
      payment_option_type = order.subscription.variant.product.option_types.find_by(name: 'payment-option')
      payment_option_value = order.subscription.variant.option_values.find_by(option_type_id: payment_option_type.id)
      payment_option_value.name == 'post-paid'
    end

    def due_days
      due_date_option_type = order.subscription.variant.product.option_types.find_by(name: 'due-date')
      due_date_option_value = order.subscription.variant.option_values.find_by(option_type_id: due_date_option_type.id)

      day = due_date_option_value.presentation.to_i

      if post_paid?
        month_option_type = order.subscription.variant.product.option_types.find_by(name: 'month')
        month_option_value = order.subscription.variant.option_values.find_by(option_type_id: month_option_type.id)

        return from_date + month_option_value.presentation.to_i.month + day.days
      end
      from_date + day.days
    end

    def validate_seats_reservation
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
                                       .where(seat_id: selected_seat_ids, date: date, variant_id: variant_id, spree_orders: { state: 'complete' })
                                       .present?
    end
  end
end

unless Spree::LineItem.included_modules.include?(SpreeCmCommissioner::LineItemDecorator)
  Spree::LineItem.prepend(SpreeCmCommissioner::LineItemDecorator)
end
