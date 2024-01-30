module SpreeCmCommissioner
  module Cart
    class RemoveGuest
      prepend ::Spree::ServiceModule::Base

      def call(order:, line_item:, guest_id: nil)
        ActiveRecord::Base.transaction do
          remove_guest(order, line_item, guest_id) if guest_id.present?
          decrease_quantity(order, line_item) if should_decrease_quantity?(line_item)
          recalculate_cart(order, line_item)

          success(order: order, line_item: line_item)
        end
      end

      private

      def remove_guest(_order, line_item, guest_id)
        guest = line_item.guests.find(guest_id)
        raise ActiveRecord::RecordNotFound if guest.nil?

        guest.destroy!
      end

      def decrease_quantity(order, line_item)
        line_item.quantity -= 1
        if line_item.quantity.zero?
          order.line_items.destroy(line_item)
        else
          line_item.save!
        end
      end

      # should decrease quantity if number of guests
      # does not fully fill a unit/quantity of line item
      def should_decrease_quantity?(line_item)
        total_guests(line_item) <= required_guests_for_previous_unit(line_item)
      end

      def total_guests(line_item)
        line_item.guests.size
      end

      def required_guests_for_previous_unit(line_item)
        number_of_guests_per_unit(line_item) * (line_item.quantity - 1)
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
