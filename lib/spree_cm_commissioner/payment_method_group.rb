module SpreeCmCommissioner
  class PaymentMethodGroup
    attr_accessor :id, :name, :payment_methods, :payment_method_ids

    def initialize(name:, payment_methods:)
      @id = SecureRandom.hex
      @name = name
      @payment_methods = payment_methods
      @payment_method_ids = payment_methods.pluck(:id)
    end
  end
end
