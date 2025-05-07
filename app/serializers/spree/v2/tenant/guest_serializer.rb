module Spree
  module V2
    module Tenant
      class GuestSerializer < BaseSerializer
        attributes :first_name, :last_name, :dob, :gender, :kyc_fields, :other_occupation, :created_at, :updated_at,
                   :qr_data, :social_contact_platform, :social_contact, :available_social_contact_platforms,
                   :age, :emergency_contact, :other_organization, :expectation, :upload_later, :address,
                   :formatted_bib_number, :phone_number, :user_id

        attribute :allowed_checkout, &:allowed_checkout?
        attribute :allowed_upload_later, &:allowed_upload_later?
        attribute :require_kyc_field, &:require_kyc_field?

        belongs_to :occupation, serializer: Spree::V2::Tenant::TaxonSerializer
        belongs_to :nationality, serializer: Spree::V2::Tenant::TaxonSerializer
        has_one :id_card, serializer: Spree::V2::Tenant::IdCardSerializer

        # allowed_checkout updates frequently
        cache_options store: nil
      end
    end
  end
end
