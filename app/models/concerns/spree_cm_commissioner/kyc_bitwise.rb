module SpreeCmCommissioner
  module KycBitwise
    extend ActiveSupport::Concern

    BIT_FIELDS = {
      guest_name: 0b1,
      guest_gender: 0b10,
      guest_dob: 0b100,
      guest_occupation: 0b1000,
      guest_id_card: 0b10000,
      guest_nationality: 0b100000,
      guest_age: 0b1000000,
      guest_emergency_contact: 0b10000000,
      guest_organization: 0b100000000,
      guest_expectation: 0b1000000000,
      guest_social_contact: 0b10000000000,
      guest_address: 0b100000000000,
      guest_phone_number: 0b1000000000000
    }.freeze

    ORDERED_BIT_FIELDS = %i[
      guest_name
      guest_gender
      guest_phone_number
      guest_dob
      guest_occupation
      guest_nationality
      guest_age
      guest_emergency_contact
      guest_organization
      guest_social_contact
      guest_address
      guest_expectation
      guest_id_card
    ].freeze

    def kyc? = kyc != 0

    BIT_FIELDS.each do |field, bit_value|
      define_method "#{field}?" do
        kyc_value_enabled?(bit_value)
      end
    end

    def unordered_kyc_fields
      BIT_FIELDS.filter_map do |field, bit_value|
        field if kyc & bit_value != 0
      end
    end

    def kyc_fields
      unordered_kyc_fields.sort_by { |item| ORDERED_BIT_FIELDS.index(item) }
    end

    def kyc_value_enabled?(bit_value)
      return false if kyc.nil?

      kyc & bit_value != 0
    end

    def available_social_contact_platforms
      platforms = SpreeCmCommissioner::Guest.social_contact_platforms.keys
      platforms.sort_by { |platform| platform == 'other' ? 1 : 0 }
    end
  end
end
