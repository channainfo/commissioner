module SpreeCmCommissioner
  module V2
    module Operator
      class LineItemOrderSerializer < BaseSerializer
        set_type :order

        has_one :user, serializer: Spree::V2::Storefront::UserSerializer
        attributes :number, :state, :phone_number, :email
      end
    end
  end
end
