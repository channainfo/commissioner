module SpreeCmCommissioner
  class UserCartItemCountJob < ApplicationUniqueJob
    queue_as :user_updates

    def perform(order_id)
      order = Spree::Order.find_by(id: order_id)
      SpreeCmCommissioner::UpdateUserCartItemCountHandler.call(order: order)
    end
  end
end
