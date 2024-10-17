module SpreeCmCommissioner
  module V2
    module Operator
      class GuestSerializer < BaseSerializer
        set_type :guest

        attributes :first_name, :last_name, :dob, :gender, :kyc_fields, :other_occupation, :created_at, :updated_at,
                   :qr_data, :social_contact_platform, :social_contact, :available_social_contact_platforms, :event_id, :seat_number,
                   :age, :emergency_contact, :other_organization, :expectation, :upload_later, :address, :formatted_bib_number, :phone_number

        attribute :allowed_checkout, &:allowed_checkout?
        attribute :require_kyc_field, &:require_kyc_field?

        belongs_to :occupation, serializer: Spree::V2::Storefront::TaxonSerializer

        has_one :check_in, serializer: SpreeCmCommissioner::V2::Operator::CheckInSerializer
        has_one :line_item, serializer: SpreeCmCommissioner::V2::Operator::LineItemSerializer
      end
    end
  end
end
