module SpreeCmCommissioner
  module V2
    module Storefront
      class GuestLineItemSerializer < BaseSerializer
        set_type :line_item

        attributes :remaining_total_guests, :quantity

        belongs_to :vendor, serializer: Spree::V2::Storefront::VendorSerializer
        has_many :guests, serializer: :guest
      end
    end
  end
end
