module Spree
  module V2
    module Organizer
      class GuestSerializer < BaseSerializer
        set_type :guest

        attributes :first_name, :last_name, :dob, :gender, :kyc_fields, :other_occupation, :created_at, :updated_at,
                   :qr_data, :social_contact_platform, :social_contact, :available_social_contact_platforms, :seat_number,
                   :age, :emergency_contact, :other_organization, :expectation, :upload_later, :address, :formatted_bib_number, :phone_number

        has_one :id_card, serializer: ::Spree::V2::Organizer::IdCardSerializer
        has_one :check_in, serializer: ::Spree::V2::Organizer::CheckInSerializer
      end
    end
  end
end
