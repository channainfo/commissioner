module SpreeCmCommissioner
  module EnqueueCart
    class AddItemJob < ApplicationUniqueJob
      def perform(order_id, variant_id, quantity, public_metadata, private_metadata, options) # rubocop:disable Metrics/ParameterLists
        SpreeCmCommissioner::EnqueueCart::AddItem.call(
          order_id: order_id,
          variant_id: variant_id,
          quantity: quantity,
          public_metadata: public_metadata,
          private_metadata: private_metadata,
          options: options,
          job_id: job_id
        )
      end
    end
  end
end
