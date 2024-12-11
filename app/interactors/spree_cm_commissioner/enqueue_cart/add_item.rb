module SpreeCmCommissioner
  module EnqueueCart
    class AddItem < BaseInteractor
      delegate :order_id, :variant_id, :job_id, :quantity, :public_metadata, :private_metadata, :options, to: :context

      def call
        result = add_item_to_cart
        if result.success?
          update_status('completed')
        else
          update_status('failed')
        end
      end

      def add_item_to_cart
        Spree::Cart::AddItem.call(
          order: order,
          variant: variant,
          quantity: quantity,
          public_metadata: public_metadata,
          private_metadata: private_metadata,
          options: options
        )
      end

      def update_status(status)
        SpreeCmCommissioner::EnqueueCart::AddItemStatusMarker.call(
          order_number: order.number,
          job_id: job_id,
          status: status
        )
      end

      def order
        @order ||= Spree::Order.find(order_id)
      end

      def variant
        @variant ||= Spree::Variant.find(variant_id)
      end
    end
  end
end
