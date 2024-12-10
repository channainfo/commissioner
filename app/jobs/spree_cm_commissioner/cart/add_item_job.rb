require 'google/cloud/firestore'

module SpreeCmCommissioner
  module Cart
    class AddItemJob < ApplicationJob
      def perform(order_id, variant_id, quantity, public_metadata, private_metadata, options) # rubocop:disable Metrics/ParameterLists
        SpreeCmCommissioner::Cart::AddItemHandler.call(
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
