module SpreeCmCommissioner
  module PaymentMethodDecorator
    DISPLAY = %i[both front_end back_end frontend_for_early_adopter].freeze

    def self.prepended(base)
      base.const_set(:DISPLAY, DISPLAY)
      base.belongs_to :vendor, class_name: 'Spree::Vendor', optional: true, inverse_of: :payment_methods

      base.scope :available_on_frontend_for_early_adopter, -> { active.where(display_on: %i[both front_end frontend_for_early_adopter]) }
    end
  end
end

unless Spree::PaymentMethod.included_modules.include?(SpreeCmCommissioner::PaymentMethodDecorator)
  Spree::PaymentMethod.prepend SpreeCmCommissioner::PaymentMethodDecorator
end
