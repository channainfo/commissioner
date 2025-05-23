module Spree
  module V2
    module Organizer
      class InviteGuestSerializer < BaseSerializer
        attributes :email, :quantity, :token, :claimed_status, :issued_to, :expires_at,
                   :claimed_at, :email_send_at, :expiration_date, :remark
        belongs_to :variant, serializer: SpreeCmCommissioner::V2::Storefront::EventVariantSerializer
        belongs_to :order, serializer: Spree::V2::Storefront::OrderSerializer
        belongs_to :taxon, serializer: Spree::V2::Storefront::TaxonSerializer
      end
    end
  end
end
