module SpreeCmCommissioner
  module LineItemDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::LineItemDurationable
      base.delegate :need_confirmation, :product_type, to: :product

      base.belongs_to :accepted_by, class_name: 'Spree::User', optional: true
      base.belongs_to :rejected_by, class_name: 'Spree::User', optional: true

      base.before_save :update_vendor_id

      base.delegate :product_type, :accommodation?, :service?, :ecommerce?, to: :product
      base.before_create :add_due_date, if: :subscription?

      base.whitelisted_ransackable_attributes |= %w[to_date from_date]
    end

    def reservation?
      date_present? && !subscription?
    end

    # date_unit could be number of nights, or days or hours depending on usecases
    # For example:
    # - accomodation uses number of nights.
    # - appointment uses number of hours, etc.
    #
    # override
    def amount
      base_price = price * quantity

      if reservation?
        base_price * date_unit
      else
        base_price
      end
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
