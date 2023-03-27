module SpreeCmCommissioner
  module OrderDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::PhoneNumberSanitizer

      base.before_create :link_by_phone_number

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
  end
end

Spree::Order.prepend(SpreeCmCommissioner::OrderDecorator) unless Spree::Order.included_modules.include?(SpreeCmCommissioner::OrderDecorator)
