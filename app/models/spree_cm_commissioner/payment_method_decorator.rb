module SpreeCmCommissioner
  module PaymentMethodDecorator
    DISPLAY = %i[both front_end back_end frontend_for_early_adopter].freeze

    def self.prepended(base)
      base.const_set(:DISPLAY, DISPLAY)

      base.scope :available_on_frontend_for_early_adopter, -> { active.where(display_on: %i[both front_end frontend_for_early_adopter]) }

      base.has_many :user_payment_options, class_name: 'SpreeCmCommissioner::UserPaymentOption'
      base.has_many :users, through: :user_payment_options, class_name: 'Spree::User'
    end
  end
end

unless Spree::PaymentMethod.included_modules.include?(SpreeCmCommissioner::PaymentMethodDecorator)
  Spree::PaymentMethod.prepend SpreeCmCommissioner::PaymentMethodDecorator
end
