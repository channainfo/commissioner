module SpreeCmCommissioner
  module Stock
    module AvailabilityValidatorDecorator
      # override
      def validate(line_item)
        return validate_seats_reservation(line_item) if line_item.transit?
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
        @line_item = line_item
        trip = reservation_trip
        allow_seat_selection = trip.allow_seat_selection

        if allow_seat_selection
          @line_item.errors.add(:base, :some_seats_are_booked, message: 'Some seats are already booked') unless selected_seats_available?
        else
          @line_item.errors.add(:quantity, :exceeded_available_quantity, message: 'exceeded available quantity') unless seat_quantity_available?(trip)
        end
      end

      def selected_seats_available?
        select_seat_ids = @line_item.booking_seats.pluck(:id)
        seat_ids_exist?(select_seat_ids, @line_item.date)
      end

      def seat_quantity_available?(trip)
        booked_quantity = Spree::LineItem.joins(:order)
                                         .where(variant_id: @line_item.variant_id, date: @line_item.date, spree_orders: { state: 'complete' })
                                         .sum(:quantity)
        remaining_quantity = trip.vehicle.number_of_seats - booked_quantity
        remaining_quantity >= @line_item.quantity
      end

      def reservation_trip
        return @trip if defined? @trip

        route = Spree::Variant.find_by(id: @line_item.variant_id).product
        @trip = route.trip
      end

      def find_booked_variants(variant_id, from_date, to_date)
        SpreeCmCommissioner::ReservationVariantQuantityAvailabilityQuery.new(variant_id, from_date, to_date).booked_variants
      end

      def seat_ids_exist?(select_seat_ids, date)
        LineItemSeat.where(seat_id: select_seat_ids, date: date).blank?
      end
    end
  end
end

unless Spree::Stock::AvailabilityValidator.included_modules.include?(SpreeCmCommissioner::Stock::AvailabilityValidatorDecorator)
  Spree::Stock::AvailabilityValidator.prepend(SpreeCmCommissioner::Stock::AvailabilityValidatorDecorator)
end
