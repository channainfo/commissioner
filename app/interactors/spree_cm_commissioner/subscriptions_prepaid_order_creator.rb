module SpreeCmCommissioner
  class SubscriptionsPrepaidOrderCreator < BaseInteractor
    delegate :customer, to: :context
    delegate :store_credit, to: :context
    delegate :duration, to: :context

    def call
      create_order
      add_subscription_variant_to_line_item
      create_adjustment
      create_payment_and_capture
      create_invoice
    end

    private

    def create_invoice
      SpreeCmCommissioner::InvoiceCreator.call(order: context.new_order) if context.new_order.present?
    end

    def create_order
      context.new_order = customer.user.orders.create(
        subscription_id: customer.subscriptions.first.id,
        phone_number: context.customer.phone_number,
        user_id: context.customer.user_id
      )
    end

    def create_payment_and_capture
      context.new_order.reload
      default_payment_method = Spree::PaymentMethod::Check.available_on_back_end.first_or_create! do |method|
        method.name ||= 'Invoice'
        method.stores = [Spree::Store.default] if method.stores.empty?
      end

      Spree::Payment.create!(
        order_id: context.new_order.id,
        payment_method: default_payment_method,
        amount: store_credit.amount
      )
      context.new_order.payments.last.capture!
      context.new_order.update(state: 'complete', payment_state: 'paid', completed_at: Time.zone.now)
    end

    def create_adjustment
      adjustment_total = if duration == 6
                           customer.subscriptions.map(&:total_price).sum * customer.vendor.six_months_discount.to_i
                         else
                           customer.subscriptions.map(&:total_price).sum * customer.vendor.twelve_months_discount.to_i
                         end
      Spree::Adjustment.create!(
        adjustable: context.new_order,
        order: context.new_order,
        adjustable_type: 'Spree::Order',
        amount: -adjustment_total,
        label: store_credit.memo || 'Prepaid Discount'
      )
      context.new_order.update_with_updater!
    end

    def add_subscription_variant_to_line_item
      today = Time.zone.today
      from_date = today
      to_date = today + duration.month
      customer.subscriptions.each do |subscription|
        Spree::Cart::AddItem.call(
          order: context.new_order,
          variant: subscription.variant,
          quantity: subscription.quantity * duration,
          options: {
            from_date: from_date,
            to_date: to_date
          }
        )
      end
    end
  end
end
