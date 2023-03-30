module SpreeCmCommissioner
  class SubscribedOrderCreator < BaseInteractor
    delegate :subscription, to: :context

    def call
      create_order
      create_line_item

      context.order.create_default_payment_if_eligble
      context.order.reload
    end

    def create_order
      context.order = subscription.orders.create!(
        subscription_id: subscription.id,
        phone_number: subscription.customer.phone_number,
        user_id: subscription.customer.user_id
      )
    end

    def create_line_item
      from_date = subscription.start_date
      to_date = from_date + subscription.months_count.months

      Spree::Cart::AddItem.call(
        order: context.order,
        variant: subscription.variant,
        quantity: 1,
        options: {
          from_date: from_date,
          to_date: to_date
        }
      )
    end
  end
end
