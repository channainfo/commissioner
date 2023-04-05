module SpreeCmCommissioner
  class SubscriptionsOrderCronExecutor < BaseInteractor
    def call
      remaining_subscriptions.find_each do |subscription|
        SpreeCmCommissioner::SubscribedOrderCreator.call(subscription: subscription)
      end
    end

    def partition_orders
      Spree::Order.select('id,number, subscription_id, rank() OVER (PARTITION BY subscription_id ORDER BY id DESC)')
                  .where.not(subscription_id: nil)
                  .order(:subscription_id)
    end

    def last_orders
      Spree::Order
        .select('po.id, po.number, po.subscription_id,po.rank')
        .joins("INNER JOIN (#{partition_orders.to_sql}) AS po ON po.id = spree_orders.id")
        .where('rank = 1')
    end

    def remaining_subscriptions
      SpreeCmCommissioner::Subscription
        .joins("INNER JOIN(#{last_orders.to_sql}) AS lo ON lo.subscription_id = cm_subscriptions.id")
        .joins('INNER JOIN spree_line_items as li on li.order_id = lo.id')
        .where('li.to_date <= ?', current)
    end

    def current
      context.current ||= Date.current
    end
  end
end
