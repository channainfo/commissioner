module SpreeCmCommissioner
  module Stock
    module AvailabilityValidatorDecorator
      # override
      def validate(line_item)
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

      def find_booked_variants(variant_id, from_date, to_date)
        VariantQuantityAvailabilityQuery.new(variant_id, from_date, to_date).booked_variants
      end
    end
  end
end

unless Spree::Stock::AvailabilityValidator.included_modules.include?(SpreeCmCommissioner::Stock::AvailabilityValidatorDecorator)
  Spree::Stock::AvailabilityValidator.prepend(SpreeCmCommissioner::Stock::AvailabilityValidatorDecorator)
end
