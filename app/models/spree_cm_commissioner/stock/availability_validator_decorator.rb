module SpreeCmCommissioner
  module Stock
    module AvailabilityValidatorDecorator
      # override
      def validate(line_item)
        return validate_seats_reservation(line_item) if line_item.seat_reservation?
        return validate_reservation(line_item) if line_item.reservation?

        super
      end

      private

      def validate_reservation(line_item)
        booked_variants = find_booked_variants(line_item.variant_id, line_item.from_date, line_item.to_date)

        line_item.date_range.each do |booking_date|
          next if booked_variants[booking_date].nil?

          available_quantity = booked_variants[booking_date][:available_quantity]

          # Example of "available_quantity - line_item.quantity"
          #
          # 3 - 1 = 2 -> available
          # 5 - 1 = 4 -> available
          #
          # 3 - 4 = -1 -> [booking_date] only available 3 rooms
          # 3 - 5 = -2 -> [booking_date] only available 3 rooms

          remaining_quantity = available_quantity - line_item.quantity
          can_supply = remaining_quantity >= 0

          next if can_supply

          line_item.errors.add(
            :quantity, :exceeded_available_quantity_on_date,
            message: Spree.t(:exceeded_available_quantity_on_date, count: [0, available_quantity].max, date: booking_date)
          )
        end
      end

      def validate_seats_reservation(line_item)
        trip = reservation_trip(line_item)
        allow_seat_selection = trip.allow_seat_selection

        if allow_seat_selection
          line_item.errors.add(:base, :some_seats_are_booked, message: 'Some seats are already booked') if validate_by_booking_seats(line_item)
        elsif validate_by_quantity(line_item, trip)
          line_item.errors.add(:quantity, :exceeded_available_quantity, message: 'exceeded available quantity')
        end
      end

      def validate_by_booking_seats(line_item)
        booked_seats = find_booked_seats(line_item.variant_id, line_item.date).pluck(:seat_id)
        booking_seats = line_item.booking_seats.pluck(:id)

        booking_seats.intersect?(booked_seats)
      end

      def validate_by_quantity(line_item, trip)
        booked_quantity = Spree::LineItem.joins(:order)
                                         .where(variant_id: line_item.variant_id, date: line_item.date, spree_orders: { state: 'complete' })
                                         .sum(:quantity)
        remaining_quantity = trip.vehicle.number_of_seats - booked_quantity
        line_item.quantity > remaining_quantity
      end

      def reservation_trip(line_item)
        route = Spree::Variant.find_by(id: line_item.variant_id).product
        route.trip
      end

      def find_booked_variants(variant_id, from_date, to_date)
        SpreeCmCommissioner::ReservationVariantQuantityAvailabilityQuery.new(variant_id, from_date, to_date).booked_variants
      end

      def find_booked_seats(trip_id, date)
        SpreeCmCommissioner::LineItemSeat.select('cm_line_item_seats.seat_id')
                                         .joins('INNER JOIN spree_line_items ON cm_line_item_seats.line_item_id = spree_line_items.id')
                                         .joins('INNER JOIN spree_orders ON spree_orders.id = spree_line_items.order_id')
                                         .where('spree_orders.state = ? ', 'complete')
                                         .where('cm_line_item_seats.variant_id = ? AND cm_line_item_seats.date = ?', trip_id, date)
      end
    end
  end
end

unless Spree::Stock::AvailabilityValidator.included_modules.include?(SpreeCmCommissioner::Stock::AvailabilityValidatorDecorator)
  Spree::Stock::AvailabilityValidator.prepend(SpreeCmCommissioner::Stock::AvailabilityValidatorDecorator)
end
