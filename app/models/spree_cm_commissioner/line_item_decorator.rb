module SpreeCmCommissioner
  module LineItemDecorator
    def self.prepended(base)
      base.before_save :update_vendor_id

      base.delegate :product_type, :accommodation?, :service?, :ecommerce?, to: :product
      base.before_create :add_due_date, if: :subscription?

      base.whitelisted_ransackable_attributes |= %w[to_date from_date]
    end

    def reservation?
      date_present? && !subscription?
    end

    def date_present?
      from_date.present? && to_date.present?
    end

    def duration
      return nil unless date_present?

      (to_date.to_date - from_date.to_date) + 1
    end

    def date_range
      return [] unless date_present?

      from_date.to_date..to_date.to_date
    end

    # override
    def amount
      base_price = price * quantity
      return base_price unless reservation?

      base_price * duration
    end

    private

    def update_vendor_id
      self.vendor_id = variant.vendor_id
    end

    def subscription?
      order.subscription.present?
    end

    def add_due_date
      self.due_date = due_days
    end

    def post_paid?
      payment_option_type = order.subscription.variant.product.option_types.find_by(name: 'payment-option')
      payment_option_value = order.subscription.variant.option_values.find_by(option_type_id: payment_option_type.id)
      payment_option_value.name == 'post-paid'
    end

    def due_days
      due_date_option_type = order.subscription.variant.product.option_types.find_by(name: 'due-date')
      due_date_option_value = order.subscription.variant.option_values.find_by(option_type_id: due_date_option_type.id)

      day = due_date_option_value.presentation.to_i

      if post_paid?
        month_option_type = order.subscription.variant.product.option_types.find_by(name: 'month')
        month_option_value = order.subscription.variant.option_values.find_by(option_type_id: month_option_type.id)

        return from_date + month_option_value.presentation.to_i.month + day.days
      end
      from_date + day.days
    end
  end
end

unless Spree::LineItem.included_modules.include?(SpreeCmCommissioner::LineItemDecorator)
  Spree::LineItem.prepend(SpreeCmCommissioner::LineItemDecorator)
end
