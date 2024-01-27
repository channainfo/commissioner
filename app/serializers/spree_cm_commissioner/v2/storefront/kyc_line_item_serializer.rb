module SpreeCmCommissioner
  module V2
    module Storefront
      class KycLineItemSerializer < BaseSerializer
        set_type :line_item

        attributes :name, :remaining_total_guests, :quantity, :kyc, :kyc_fields

        belongs_to :vendor, serializer: Spree::V2::Storefront::VendorSerializer
        has_many :guests, serializer: :guest
      end
    end
  end
end
