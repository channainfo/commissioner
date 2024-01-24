module SpreeCmCommissioner
  module LineItemDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::LineItemDurationable
      base.include SpreeCmCommissioner::LineItemsFilterScope
      base.include SpreeCmCommissioner::ProductDelegation
      base.include SpreeCmCommissioner::KycBitwise

      base.belongs_to :accepter, class_name: 'Spree::User', optional: true
      base.belongs_to :rejecter, class_name: 'Spree::User', optional: true

      base.has_many :taxons, class_name: 'Spree::Taxon', through: :product
      base.has_many :guests, class_name: 'SpreeCmCommissioner::Guest', dependent: :destroy

      base.before_save :update_vendor_id

      base.before_create :add_due_date, if: :subscription?

      base.whitelisted_ransackable_attributes |= %w[to_date from_date]

      def base.json_api_columns
        json_api_columns = column_names.reject { |c| c.match(/_id$|id|preferences|(.*)password|(.*)token|(.*)api_key/) }
        json_api_columns << :options_text
        json_api_columns << :vendor_id
      end
    end

    def reservation?
      (accommodation? || service?) && date_present? && !subscription?
    end

    # date_unit could be number of nights, or days or hours depending on usecases
    # For example:
    # - accomodation uses number of nights.
    # - appointment uses number of hours, etc.
    #
    # override
    def amount
      base_price = price * quantity

      if reservation? && date_unit
        base_price * date_unit
      else
        base_price
      end
    end

    def amount_per_guest
      amount / quantity
    end

    def accepted?
      accepted_at.present?
    end

    def rejected?
      rejected_at.present?
    end

    def accepted_by(user)
      return if accepted_at.present? && accepter_id.present?

      update(
        accepted_at: Time.current,
        accepter: user
      )
    end

    def remaining_total_guests
      quantity - guests.count
    end

    def rejected_by(user)
      return if rejected_at.present? && rejecter_id.present?

      update(
        rejected_at: Time.current,
        rejecter: user
      )
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
