module SpreeCmCommissioner
  module V2
    module Storefront
      class PaymentMethodGroupSerializer < BaseSerializer
        attributes :name

        has_many :payment_methods, serializer: ::Spree::V2::Storefront::PaymentMethodSerializer
      end
    end
  end
end
