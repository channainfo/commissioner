module SpreeCmCommissioner
  module V2
    module Storefront
      class GuestSerializer < BaseSerializer
        set_type :guest

        attributes :first_name, :last_name, :dob, :gender, :kyc_fields, :other_occupation, :created_at, :updated_at,
                   :qr_data,
                   :age, :emergency_contact, :other_organization, :expectation, :upload_later

        attribute :allowed_checkout, &:allowed_checkout?

        belongs_to :occupation, serializer: Spree::V2::Storefront::TaxonSerializer
        belongs_to :nationality, serializer: Spree::V2::Storefront::TaxonSerializer

        has_one :id_card, serializer: Spree::V2::Storefront::IdCardSerializer
        has_one :check_in

        belongs_to :line_item, serializer: Spree::V2::Storefront::LineItemSerializer

        # allowed_checkout updates frequently
        cache_options store: nil
      end
    end
  end
end
