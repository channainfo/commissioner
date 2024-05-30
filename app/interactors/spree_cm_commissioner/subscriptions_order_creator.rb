module SpreeCmCommissioner
  class SubscriptionsOrderCreator < BaseInteractor
    delegate :customer, to: :context

    def call
      return if context.customer.orders.blank?

      if last_invoice_date.month == Date.current.month
        context.fail!(error: 'Invoice for this month is already existed')
      else
        create_order
        create_invoice

        context.new_order.create_default_payment_if_eligble
        context.new_order.reload
      end
    end

    def create_order
      active_subscriptions = context.customer.active_subscriptions
      return if active_subscriptions.blank?

      context.new_order = customer.user.orders.create!(
        subscription_id: active_subscriptions.first.id,
        phone_number: context.customer.phone_number,
        user_id: context.customer.user_id
      )

      active_subscriptions.each do |subscription|
        Spree::Cart::AddItem.call(
          order: context.new_order,
          variant: subscription.variant,
          quantity: subscription.quantity,
          options: {
            from_date: Time.zone.today,
            to_date: Time.zone.today + 1.month
          }
        )
      end
    end

    def create_invoice
      SpreeCmCommissioner::InvoiceCreator.call(order: context.new_order)
    end

    def last_invoice_date
      context.customer.orders.last.invoice.date
    end
  end
end
