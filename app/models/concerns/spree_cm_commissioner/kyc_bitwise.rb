module SpreeCmCommissioner
  module KycBitwise
    extend ActiveSupport::Concern

    BIT_FIELDS = {
      guest_name: 0b000001,
      guest_gender: 0b000010,
      guest_dob: 0b000100,
      guest_occupation: 0b001000,
      guest_id_card: 0b010000,
      guest_nationality: 0b100000
    }.freeze

    def kyc? = kyc != 0

    BIT_FIELDS.each do |field, bit_value|
      define_method "#{field}?" do
        kyc_value_enabled?(bit_value)
      end
    end

    def kyc_fields
      BIT_FIELDS.filter_map do |field, bit_value|
        field if kyc & bit_value != 0
      end
    end

    def kyc_value_enabled?(bit_value)
      kyc & bit_value != 0
    end
  end
end
