module SpreeCmCommissioner
  module KycBitwise
    extend ActiveSupport::Concern

    BIT_FIELDS = {
      guest_name: 0b00001,
      guest_gender: 0b00010,
      guest_dob: 0b00100,
      guest_occupation: 0b01000,
      guest_id_card: 0b10000
    }.freeze

    BIT_FIELDS.each do |field, bit_value|
      define_method "#{field}?" do
        kyc & bit_value != 0
      end
    end

    def kyc_fields
      BIT_FIELDS.filter_map do |field, bit_value|
        field if kyc & bit_value != 0
      end
    end
  end
end
