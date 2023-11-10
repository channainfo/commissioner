module SpreeCmCommissioner
  class WebhookSubscriberOrdersSender < BaseInteractor
    delegate :webhooks_subscriber, :order_state, to: :context

    def call
      load_scope
      filter_orders

      queue_webhooks_requests
    end

    def load_scope
      context.orders = Spree::Order.where(state: order_state)
    end

    def filter_orders
      webhooks_subscriber.rules.each do |rule|
        context.orders = rule.filter(context.orders)
      end
    end

    def queue_webhooks_requests
      context.orders.each do |order|
        order.queue_webhooks_requests!('order.placed')
      end
    end
  end
end
