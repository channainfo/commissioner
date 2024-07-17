module SpreeCmCommissioner
  module Admin
    module ProductTypeHelper
      def calculate_product_type_value(params)
        product_type_params = params.slice(*SpreeCmCommissioner::ProductTypeBitwise::BIT_SEGMENT.keys)

        return nil unless product_type_params.values.any?

        product_type_params.values.each_with_index.sum do |value, index|
          value.to_i * (2**index)
        end
      end
    end
  end
end
