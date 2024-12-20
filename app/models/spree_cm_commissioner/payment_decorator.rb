module SpreeCmCommissioner
  module PaymentDecorator
    def self.prepended(base)
      base.attr_accessor :current_user_instance

      base.belongs_to :payable, polymorphic: true, optional: true

      base.before_save :set_payable

      base.whitelisted_ransackable_attributes |= %w[payable_id]
    end

    # @override
    # order trigger payment.process! when calling order.next.
    def process!
      return complete! if payment_receive_manually?

      super
    end

    def payment_receive_manually?
      check_payment_method? && payment_method.auto_capture? && order.ticket_seller_user?
    end

    def check_payment_method?
      payment_method.is_a?(Spree::PaymentMethod::Check)
    end

    def can_void?
      state.in? %i[pending processing completed checkout]
    end

    # must set current_user_instance
    # before hand
    def set_payable
      self.payable = current_user_instance.presence if completed?
    end
  end
end

Spree::Payment.prepend(SpreeCmCommissioner::PaymentDecorator) unless Spree::Payment.included_modules.include?(SpreeCmCommissioner::PaymentDecorator)
