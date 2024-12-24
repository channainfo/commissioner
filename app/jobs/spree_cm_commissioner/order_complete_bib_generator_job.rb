module SpreeCmCommissioner
  class OrderCompleteBibGeneratorJob < ApplicationJob
    def perform(order_id)
      order = ::Spree::Order.find(order_id)
      order.generate_bib_number!
    end
  end
end
