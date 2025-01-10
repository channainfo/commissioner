# queue_webhooks_requests! already contains queue job, but before it prepare to call queue_webhooks_requests!,
# it could raise serializer error which needed to be recorded in queue dashboard.
module SpreeCmCommissioner
  class QueueOrderWebhooksRequestsJob < ApplicationUniqueJob
    def perform(options)
      order_id = options[:order_id]
      event = options[:event]

      order = Spree::Order.find(order_id)
      order.queue_webhooks_requests!(event)
    end
  end
end
