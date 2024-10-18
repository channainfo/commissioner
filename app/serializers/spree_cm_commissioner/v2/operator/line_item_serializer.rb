module SpreeCmCommissioner
  module V2
    module Operator
      class LineItemSerializer < BaseSerializer
        set_type :line_item

        attributes :number, :name, :quantity, :options_text, :qr_data, :kyc_fields, :available_social_contact_platforms

        belongs_to :order, serializer: SpreeCmCommissioner::V2::Operator::LineItemOrderSerializer
        has_one  :variant, serializer: SpreeCmCommissioner::V2::Storefront::EventVariantSerializer
        has_many :guests, serializer: SpreeCmCommissioner::V2::Operator::GuestSerializer
      end
    end
  end
end
