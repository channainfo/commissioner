module SpreeCmCommissioner
  module V2
    module Operator
      class LineItemOrderSerializer < BaseSerializer
        set_type :order

        has_one :user, serializer: Spree::V2::Storefront::UserSerializer
        belongs_to :billing_address,
                   id_method_name: :bill_address_id,
                   record_type: :address,
                   serializer: Spree::V2::Storefront::AddressSerializer

        attributes :number, :state, :phone_number, :email, :qr_data, :item_count
      end
    end
  end
end
