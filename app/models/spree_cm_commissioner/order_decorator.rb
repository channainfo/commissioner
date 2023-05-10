module SpreeCmCommissioner
  module OrderDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::PhoneNumberSanitizer

      base.scope :subscription, -> { where.not(subscription_id: nil) }

      base.after_save :send_order_complete_notification, if: :state_changed_to_complete?

      base.before_create :link_by_phone_number
      base.before_create :associate_customer

      base.validates :phone_number, presence: true, if: :require_phone_number
      base.has_one :invoice, dependent: :destroy, class_name: 'SpreeCmCommissioner::Invoice'

      base.belongs_to :subscription, class_name: 'SpreeCmCommissioner::Subscription', optional: true

      base.delegate :customer, to: :subscription, allow_nil: true
    end

    # required only in one case,
    # some of line_items are ecommerce & not digital.
    def delivery_required?
      contain_non_digital_ecommerce?
    end

    def contain_non_digital_ecommerce?
      line_items.select { |item| item.ecommerce? && !item.digital? }.size.positive?
    end

    # assume check is default payment method for subscription
    def create_default_payment_if_eligble
      return unless subscription?

      default_payment_method = Spree::PaymentMethod::Check.available_on_back_end.first_or_create! do |method|
        method.name ||= 'Invoice'
        method.stores = [Spree::Store.default] if method.stores.empty?
      end

      payments.create!(
        payment_method: default_payment_method,
        amount: order_total_after_store_credit
      )

      Spree::Checkout::Advance.call(order: self)
    end

    def subscription?
      subscription.present?
    end

    private

    def link_by_phone_number
      return if phone_number.present?

      self.phone_number = user.phone_number if user
    end

    def require_phone_number
      require_contact
    end

    def require_email
      require_contact
    end

    def require_contact
      return false if phone_number.present? || email.present?

      true unless new_record? || %w[cart address].include?(state)
    end

    def associate_customer
      return unless customer

      self.bill_address ||= customer.bill_address.try(:clone)
      self.ship_address ||= customer.ship_address.try(:clone)
    end

    def send_order_complete_notification
      SpreeCmCommissioner::OrderCompleteNotificationSender.call(order: self)
    end

    def state_changed_to_complete?
      saved_change_to_state? && state == 'complete'
    end
  end
end

Spree::Order.prepend(SpreeCmCommissioner::OrderDecorator) unless Spree::Order.included_modules.include?(SpreeCmCommissioner::OrderDecorator)
