module Spree
  module V2
    module Storefront
      module LineItemSerializerDecorator
        def self.prepended(base)
          base.attributes :from_date, :to_date, :need_confirmation, :product_type, :event_status, :amount, :display_amount,
                          :number, :qr_data,
                          :kyc, :kyc_fields, :remaining_total_guests, :number_of_guests,
                          :completion_steps

          base.attribute :allowed_self_check_in, &:allowed_self_check_in?
          base.attribute :delivery_required, &:delivery_required?

          base.has_one :vendor

          base.belongs_to :order, serializer: Spree::V2::Storefront::OrderSerializer

          base.has_one :google_wallet, serializer: SpreeCmCommissioner::V2::Storefront::GoogleWalletSerializer

          base.has_many :guests, serializer: SpreeCmCommissioner::V2::Storefront::GuestSerializer

          base.has_many :pending_guests, serializer: SpreeCmCommissioner::V2::Storefront::GuestSerializer

          # completion_steps updates frequently
          base.cache_options store: nil
          base.has_many :taxon_star_ratings, serializer: SpreeCmCommissioner::V2::Storefront::TaxonStarRatingSerializer
        end
      end
    end
  end
end

Spree::V2::Storefront::LineItemSerializer.prepend Spree::V2::Storefront::LineItemSerializerDecorator
