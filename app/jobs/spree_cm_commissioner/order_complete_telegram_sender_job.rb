# queue_webhooks_requests! already contains queue job, but before it prepare to call queue_webhooks_requests!,
# it could raise serializer error which needed to be recorded in queue dashboard.
module SpreeCmCommissioner
  class OrderCompleteTelegramSenderJob < ApplicationUniqueJob
    queue_as :telegram_bot

    def perform(order_id)
      order = Spree::Order.find(order_id)
      SpreeCmCommissioner::OrderCompleteTelegramSender.call(order: order)
    end
  end
end
