module SpreeCmCommissioner
  module V2
    module Storefront
      class GuestSerializer < BaseSerializer
        set_type :guest

        attributes :first_name, :last_name, :dob, :gender, :kyc_fields, :other_occupation, :created_at, :updated_at,
                   :qr_data, :social_contact_platform, :social_contact, :available_social_contact_platforms,
                   :age, :emergency_contact, :other_organization, :expectation, :upload_later, :address, :formatted_bib_number

        # temporary, once app release after cm-app v1.9.1, we no longer need this.
        attribute :seat_number do |object|
          object.seat_number || object.formatted_bib_number
        end

        attribute :allowed_checkout, &:allowed_checkout?
        attribute :allowed_upload_later, &:allowed_upload_later?

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
