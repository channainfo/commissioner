module SpreeCmCommissioner
  module V2
    module Storefront
      class CheckInSerializer < BaseSerializer
        set_type :check_in

        attributes :verification_state, :check_in_type, :entry_type, :check_in_method, :confirmed_at, :token

        belongs_to :line_item, serializer: ::Spree::V2::Storefront::LineItemSerializer
        belongs_to :guest, serializer: ::SpreeCmCommissioner::V2::Storefront::GuestSerializer
        belongs_to :order, serializer: ::Spree::V2::Storefront::OrderSerializer
      end
    end
  end
end
