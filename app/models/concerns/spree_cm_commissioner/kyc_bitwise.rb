module SpreeCmCommissioner
  module KycBitwise
    extend ActiveSupport::Concern

    BIT_FIELDS = {
      customer_name: 0b00001,
      customer_gender: 0b00010,
      customer_dob: 0b00100,
      customer_occupation: 0b01000,
      customer_id_card: 0b10000
    }.freeze

    BIT_FIELDS.each do |field, bit_value|
      define_method "#{field}?" do
        kyc & bit_value != 0
      end
    end
  end
end
