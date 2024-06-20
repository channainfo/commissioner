module SpreeCmCommissioner
  class SubscribedOrderCreator < BaseInteractor
    delegate :subscription, to: :context

    def call
      # reject if locked?
      today = Time.zone.today
      start_date = subscription.start_date
      return if  start_date.beginning_of_month > today.beginning_of_month
      return unless subscription.update(last_occurence: subscription.renewal_date)

      find_or_create_order
      set_last_invoice_date
      create_line_item
      create_invoice

      context.order.create_default_payment_if_eligble
      context.order.reload
    end

    private

    def find_or_create_order
      customer = subscription.customer
      context.order = customer.orders.last

      return if context.order

      context.order = customer.user.orders.create!(
        subscription_id: subscription.id,
        phone_number: subscription.customer.phone_number,
        user_id: subscription.customer.user_id
      )
    end

    def create_line_item
      return unless subscription.last_occurence

      from_date = subscription.last_occurence
      to_date = from_date + subscription.months_count.months
      existing_line_item = context.order.line_items.find_by(variant_id: subscription.variant_id)
      if existing_line_item
        existing_line_item.update(quantity: subscription.quantity)
      else
        Spree::Cart::AddItem.call(
          order: context.order,
          variant: subscription.variant,
          quantity: subscription.quantity,
          options: {
            from_date: from_date,
            to_date: to_date
          }
        )
      end
    end

    def set_last_invoice_date
      last_invoice_date = context.subscription.customer.last_invoice_date
      return if last_invoice_date.present? && last_invoice_date.beginning_of_month > Time.zone.now.beginning_of_month

      context.subscription.customer.last_invoice_date = Time.zone.now
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
