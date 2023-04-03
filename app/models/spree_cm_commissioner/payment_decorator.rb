module SpreeCmCommissioner
  module PaymentDecorator
    def self.prepended(base)
      base.attr_accessor :current_user_instance

      base.belongs_to :payable, polymorphic: true, optional: true

      base.before_save :set_payable
    end

    # must set current_user_instance
    # before hand
    def set_payable
      self.payable = current_user_instance.presence if completed?
    end
  end
end

Spree::Payment.prepend(SpreeCmCommissioner::PaymentDecorator) unless Spree::Payment.included_modules.include?(SpreeCmCommissioner::PaymentDecorator)
