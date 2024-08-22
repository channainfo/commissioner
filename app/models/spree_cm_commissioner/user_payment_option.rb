module SpreeCmCommissioner
  class UserPaymentOption < Base
    belongs_to :user, class_name: 'Spree::User', optional: false
    belongs_to :payment_method, class_name: 'Spree::PaymentMethod', optional: false
  end
end
