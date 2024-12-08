module SpreeCmCommissioner
  class AddItemJob < ApplicationJob
    queue_as :default

    def perform(order, variant, quantity, public_metadata, private_metadata, options) # rubocop:disable Metrics/ParameterLists
      SpreeCmCommissioner::Cart::AddItem.call(
        order: order,
        variant: variant,
        quantity: quantity,
        public_metadata: public_metadata,
        private_metadata: private_metadata,
        options: options
      )
    end
  end
end
