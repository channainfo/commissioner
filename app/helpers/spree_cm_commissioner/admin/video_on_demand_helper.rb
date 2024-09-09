module SpreeCmCommissioner
  module Admin
    module VideoOnDemandHelper
      def calculate_quality_value(params)
        quality_params = params.slice(*SpreeCmCommissioner::VideoOnDemandBitwise::QUALITY_BIT_FIELDS.keys)
        return nil unless quality_params.values.any?(&:present?)

        quality_params.values.each_with_index.sum do |value, index|
          value.to_i * (2**index)
        end
      end

      def calculate_protocol_value(params)
        protocol_params = params.slice(*SpreeCmCommissioner::VideoOnDemandBitwise::PROTOCOL_BIT_FIELDS.keys)
        return nil unless protocol_params.values.any?(&:present?)

        protocol_params.values.each_with_index.sum do |value, index|
          value.to_i * (2**index)
        end
      end
    end
  end
end
