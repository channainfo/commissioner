module Spree
  module V2
    module Storefront
      class LineItemOrderSerializer < BaseSerializer
        set_type :order

        has_one :user, serializer: Spree::V2::Storefront::UserSerializer
        attributes :number, :state
      end
    end
  end
end
