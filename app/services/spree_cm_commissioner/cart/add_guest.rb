module SpreeCmCommissioner
  module Cart
    class AddGuest
      prepend Spree::ServiceModule::Base

      def call(order:, line_item:)
        ActiveRecord::Base.transaction do
          create_blank_guest(line_item)
          increase_quantity(line_item) if should_increase_quantity?(line_item)
          recalculate_cart(order, line_item)

          success(order: order, line_item: line_item)
        end
      end

      private

      def create_blank_guest(line_item)
        line_item.guests.new.save(validate: false)
      end

      def increase_quantity(line_item)
        line_item.quantity += 1
        line_item.save
      end

      def should_increase_quantity?(line_item)
        total_guests(line_item) >= required_guests_for_next_unit(line_item)
      end

      # total number of guests:
      # including existing guests, remaining guests, and new guest
      def total_guests(line_item)
        existing_guests = line_item.guests.size
        remaining_total_guests = [line_item.remaining_total_guests, 0].max
        new_guest_count = 1

        existing_guests + remaining_total_guests + new_guest_count
      end

      def required_guests_for_next_unit(line_item)
        total_guests_per_unit = number_of_guests_per_unit(line_item)
        total_guests_per_unit * (line_item.quantity + 1)
      end

      def number_of_guests_per_unit(line_item)
        line_item.variant.number_of_guests
      end

      def recalculate_cart(order, line_item)
        ::Spree::Dependencies.cart_recalculate_service.constantize.call(line_item: line_item, order: order)
      end
    end
  end
end
