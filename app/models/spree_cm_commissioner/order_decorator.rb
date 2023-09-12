module SpreeCmCommissioner
  module OrderDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::PhoneNumberSanitizer
      base.include SpreeCmCommissioner::OrderRequestable

      base.scope :subscription, -> { where.not(subscription_id: nil) }

      base.scope :filter_by_event, lambda { |event|
        where(state: :complete, payment_state: :paid).where.not(approved_by: nil) if event == 'upcomming'
      }

      base.scope :filter_by_request_state, -> { where(state: :complete, payment_state: :paid).where.not(request_state: nil) }

      base.after_save :send_order_complete_notification, if: :state_changed_to_complete?

      base.before_create :link_by_phone_number
      base.before_create :associate_customer

      base.validates :phone_number, presence: true, if: :require_phone_number
      base.has_one :invoice, dependent: :destroy, class_name: 'SpreeCmCommissioner::Invoice'

      base.belongs_to :subscription, class_name: 'SpreeCmCommissioner::Subscription', optional: true
      base.has_many :customer, class_name: 'SpreeCmCommissioner::Customer', through: :subscription
      base.has_many :taxon, class_name: 'Spree::Taxon', through: :customer
      base.has_many :vendors, through: :products, class_name: 'Spree::Vendor'

      base.delegate :customer, to: :subscription, allow_nil: true

      base.whitelisted_ransackable_associations |= %w[customer taxon payments]
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

    def customer_address
      bill_address || ship_address
    end

    private

    # override :spree_api
    def webhook_payload_body
      resource_serializer.new(
        self,
        include: included_relationships.reject { |e| %i[shipments state_changes].include?(e) }
      ).serializable_hash.to_json
    end

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
  end
end

Spree::Order.prepend(SpreeCmCommissioner::OrderDecorator) unless Spree::Order.included_modules.include?(SpreeCmCommissioner::OrderDecorator)
