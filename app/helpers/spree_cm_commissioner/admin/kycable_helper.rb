module SpreeCmCommissioner
  module Admin
    module KycableHelper
      def calculate_kyc_value(params)
        kyc_params = params.slice(:customer_name, :customer_gender, :customer_dob, :customer_occupation, :customer_id_card)
        return nil unless kyc_params.values.any?(&:present?)

        kyc_params.values.each_with_index.sum do |value, index|
          value.to_i * (2**index)
        end
      end
    end
  end
end
