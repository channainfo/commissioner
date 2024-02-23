module SpreeCmCommissioner
  module V2
    module Operator
      class CheckInSerializer < BaseSerializer
        set_type :check_in

        attributes :guest_id,
                   :verification_state,
                   :check_in_type,
                   :entry_type,
                   :check_in_method,
                   :confirmed_at,
                   :token

        belongs_to :check_in_by, serializer: ::Spree::V2::Storefront::UserSerializer
        belongs_to :guest, serializer: ::SpreeCmCommissioner::V2::Operator::GuestSerializer
        belongs_to :line_item, serializer: ::SpreeCmCommissioner::V2::Operator::LineItemSerializer
      end
    end
  end
end
