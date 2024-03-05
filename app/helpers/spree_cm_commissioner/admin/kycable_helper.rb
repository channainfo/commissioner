module SpreeCmCommissioner
  module Admin
    module KycableHelper
      def calculate_kyc_value(params)
        kyc_params = params.slice(:guest_name, :guest_gender, :guest_dob, :guest_occupation, :guest_id_card, :guest_nationality)
        return nil unless kyc_params.values.any?(&:present?)

        kyc_params.values.each_with_index.sum do |value, index|
          value.to_i * (2**index)
        end
      end
    end
  end
end
