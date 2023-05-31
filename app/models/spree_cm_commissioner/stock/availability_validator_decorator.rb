module SpreeCmCommissioner
  module Stock
    module AvailabilityValidatorDecorator
      def display_name(line_item)
        display_name = line_item.variant.name.to_s
        display_name += " (#{line_item.variant.options_text})" if line_item.variant.options_text.present?
        display_name.inspect
      end

      # override
      def validate(line_item)
        return super unless line_item.reservation?

        return unless validate_perminent_stock(line_item)
        return unless validate_with_booked_dates(line_item)
      end

      def validate_perminent_stock(line_item)
        exceed_perminent_stock = line_item.quantity > line_item.variant.permanent_stock
        return true unless exceed_perminent_stock

        line_item.errors.add(:quantity, :selected_quantity_not_available,
                             message: Spree.t(:selected_quantity_not_available, item: display_name(line_item))
        )

        line_item.errors.none?
      end

      def validate_with_booked_dates(line_item)
        booked_line_items = booked_line_items(line_item)
        return true if booked_line_items.none?

        booked_line_items.each do |booked_line_item|
          booked_line_item.date_range.each do |booked_date|
            next unless line_item.date_range.include?(booked_date)

            line_item.errors.add(
              :quantity, :selected_item_not_available_on_date,
              message: Spree.t(
                :selected_item_not_available_on_date,
                item: display_name(line_item),
                date: booked_date.to_date
              )
            )
          end
        end

        line_item.errors.none?
      end

      def booked_line_items(line_item)
        line_item.variant.line_items.where('(from_date <= ? AND to_date >= ?)', line_item.to_date, line_item.from_date)
      end
    end
  end
end

unless Spree::Stock::AvailabilityValidator.included_modules.include?(SpreeCmCommissioner::Stock::AvailabilityValidatorDecorator)
  Spree::Stock::AvailabilityValidator.prepend(SpreeCmCommissioner::Stock::AvailabilityValidatorDecorator)
end
