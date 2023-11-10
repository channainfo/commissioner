module SpreeCmCommissioner
  class WebhookSubscriberOrdersSenderJob < ApplicationJob
    def perform(options)
      order_state = options[:order_state]
      webhooks_subscriber_id = options[:webhooks_subscriber_id]

      webhooks_subscriber = Spree::Webhooks::Subscriber.find(webhooks_subscriber_id)
      SpreeCmCommissioner::WebhookSubscriberOrdersSender.call(
        order_state: order_state,
        webhooks_subscriber: webhooks_subscriber
      )
    end
  end
end
