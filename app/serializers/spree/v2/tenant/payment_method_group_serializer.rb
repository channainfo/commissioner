module Spree
  module V2
    module Tenant
      class PaymentMethodGroupSerializer < BaseSerializer
        attributes :name

        has_many :payment_methods, serializer: Spree::V2::Tenant::PaymentMethodSerializer
      end
    end
  end
end
