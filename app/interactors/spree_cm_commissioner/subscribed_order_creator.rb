module SpreeCmCommissioner
  class SubscribedOrderCreator < BaseInteractor
    delegate :subscription, to: :context

    def call
      # reject if locked?
      return unless subscription.update(last_occurence: subscription.renewal_date)

      create_order
      create_line_item
      create_invoice

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
      from_date = subscription.last_occurence
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

    def renewal_date
      return subscription.start_date if subscription.last_occurence.blank?

      subscription.last_occurence + months_count
    end

    def months_count
      subscription.months_count.months
    end

    def create_invoice
      SpreeCmCommissioner::InvoiceCreator.call(order: context.order)
    end
  end
end
