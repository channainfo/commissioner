module SpreeCmCommissioner
  class SubscriptionsOrderCreator < BaseInteractor
    delegate :customer, to: :context
    def call
      today = Time.zone.today.beginning_of_month
      last_invoice_date = context.customer.last_invoice_date || (today - 1.month)
      active_subscriptions = active_subscriptions_query(today)

      return context.fail!(error: 'Invoice for this month is already existed') if last_invoice_date.beginning_of_month == today

      return context.fail!(error: 'There are no active subscriptions') if active_subscriptions.blank?

      return unless last_invoice_date.beginning_of_month < today

      missed_months = missed_months(last_invoice_date.beginning_of_month, today)
      missed_months.times do |i|
        month = i + 1
        generate_invoice(last_invoice_date, month, active_subscriptions)
      end
      context.customer.update(last_invoice_date: Time.zone.now)
    end

    private

    def missed_months(date, today)
      ((today.year * 12) + today.month) - ((date.year * 12) + date.month)
    end

    def create_order(active_subscriptions)
      context.new_order = customer.user.orders.create!(
        subscription_id: active_subscriptions.first.id,
        phone_number: context.customer.phone_number,
        user_id: context.customer.user_id
      )
    end

    def generate_invoice(last_invoice_date, month, active_subscriptions)
      create_order(active_subscriptions)
      add_subscription_variant_to_line_item(last_invoice_date, active_subscriptions, month)
      create_invoice

      context.new_order.create_default_payment_if_eligble
      context.new_order.reload
      context.customer.reload
    end

    def add_subscription_variant_to_line_item(last_invoice_date, active_subscriptions, month)
      from_date = last_invoice_date + month.month
      to_date = from_date + 1.month
      active_subscriptions.each do |subscription|
        next if subscription.start_date.beginning_of_month > from_date.beginning_of_month

        Spree::Cart::AddItem.call(
          order: context.new_order,
          variant: subscription.variant,
          quantity: subscription.quantity,
          options: {
            from_date: from_date,
            to_date: to_date
          }
        )
      end
    end

    def active_subscriptions_query(today)
      context.customer.active_subscriptions.where(
        'EXTRACT(YEAR FROM start_date) < ? OR (EXTRACT(YEAR FROM start_date) = ? AND EXTRACT(MONTH FROM start_date) <= ?)',
        today.year, today.year, today.month
      )
    end

    def create_invoice
      SpreeCmCommissioner::InvoiceCreator.call(order: context.new_order)
    end
  end
end
