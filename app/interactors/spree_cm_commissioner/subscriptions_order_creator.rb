module SpreeCmCommissioner
  class SubscriptionsOrderCreator < BaseInteractor
    delegate :customer, to: :context
    def call
      today = Time.zone.today
      if today.day < 15
        period_start = (today - 1.month).change(day: 15)
        period_end = today.change(day: 14)
        boundary_date = today.prev_month.change(day: 14)
      else
        period_start = today.change(day: 15)
        period_end = (today + 1.month).change(day: 14)
        boundary_date = today.change(day: 14)
      end
      last_invoice_date = customer.last_invoice_date || boundary_date

      period = period_start..period_end
      return context.fail!(error: 'Invoice for this month is already existed') if period.cover?(last_invoice_date)

      active_subscriptions = active_subscriptions_query(boundary_date)
      return context.fail!(error: 'There are no active subscriptions') if active_subscriptions.blank?

      missed_months = missed_months(last_invoice_date, boundary_date)
      missed_months.times do |i|
        month = i
        generate_invoice(last_invoice_date, month, active_subscriptions, boundary_date)
      end
      context.customer.update(last_invoice_date: Time.zone.now)
    end

    private

    def missed_months(last_invoice_date, boundary_date)
      adjusted_last_invoice_date = last_invoice_date.day < 15 ? last_invoice_date.change(day: 15).prev_month : last_invoice_date.change(day: 15)
      boundary_date_diff = (boundary_date.year * 12) + boundary_date.month
      adjusted_last_invoice_date_diff = (adjusted_last_invoice_date.year * 12) + adjusted_last_invoice_date.month

      (boundary_date_diff - adjusted_last_invoice_date_diff).clamp(0, Float::INFINITY)
    end

    def create_order(active_subscriptions)
      context.new_order = customer.user.orders.create!(
        subscription_id: active_subscriptions.first.id,
        phone_number: context.customer.phone_number,
        user_id: context.customer.user_id
      )
    end

    def generate_invoice(last_invoice_date, month, active_subscriptions, boundary_date)
      create_order(active_subscriptions)
      add_subscription_variant_to_line_item(last_invoice_date, active_subscriptions, month, boundary_date)
      create_invoice

      context.new_order.create_default_payment_if_eligble
      context.new_order.reload
      context.customer.reload
    end

    def add_subscription_variant_to_line_item(last_invoice_date, active_subscriptions, month, _boundary_date)
      # 1 May 15th, June 14th
      # 2 June 15th, July 14th
      # 3 July 15th, August 14th
      from_date = customer.last_invoice_date.blank? ? last_invoice_date + month.month + 1.day : last_invoice_date + month.month
      to_date = from_date + 1.month
      active_subscriptions.each do |subscription|
        next if subscription.start_date >= to_date

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

    def active_subscriptions_query(boundary_date)
      context.customer.active_subscriptions.where('start_date <= ?', boundary_date)
    end

    def create_invoice
      SpreeCmCommissioner::InvoiceCreator.call(order: context.new_order) if context.new_order.present?
    end
  end
end
