module SpreeCmCommissioner
  module Cart
    class BrowseGuest
      prepend Spree::ServiceModule::Base

      def call(order:, line_item:, guest_params: {})
        ApplicationRecord.transaction do
          create_guest(line_item, guest_params)
          recalculate_cart(order, line_item)

          success(order: order, line_item: line_item)
        end
      end

      private

      def create_guest(line_item, guest_params)
        line_item.guests.new(guest_params).save(validate: false)
      end

      def recalculate_cart(order, line_item)
        ::Spree::Dependencies.cart_recalculate_service.constantize.call(line_item: line_item, order: order)
      end
    end
  end
end
