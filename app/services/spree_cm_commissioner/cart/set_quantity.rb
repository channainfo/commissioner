module SpreeCmCommissioner
  module Cart
    class SetQuantity < Spree::Api::V2::ResourceController
      prepend Spree::ServiceModule::Base

      def call(order:, line_item:, guests_to_remove:, quantity: nil)
        ActiveRecord::Base.transaction do
          remove_guests(guests_to_remove: guests_to_remove) if guests_to_remove.present?
          change_item_quantity(order: order, line_item: line_item, quantity: quantity)
          Recalculate.call(order: order, line_item: line_item)
        end
      end

      private

      def remove_guests(guests_to_remove:)
        guests_to_remove.each do |guest_id|
          guest = SpreeCmCommissioner::Guest.find(guest_id)
          guest.destroy if guest.present?
        end
      end

      def change_item_quantity(order:, line_item:, quantity: nil)
        return failure(line_item) unless line_item.update(quantity: quantity)

        success(order: order, line_item: line_item)
      end
    end
  end
end
