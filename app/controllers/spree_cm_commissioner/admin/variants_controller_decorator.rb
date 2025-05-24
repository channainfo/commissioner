module SpreeCmCommissioner
  module Admin
    module VariantsControllerDecorator
      include SpreeCmCommissioner::Admin::KycableHelper

      def self.prepended(base)
        base.before_action :build_option_values_form, only: %i[edit new]
        base.before_action :build_option_values, only: %i[create update]
        base.before_action :build_guest_info, only: %i[create update]
      end

      # build option values that not exist. All option values will display to UI.
      def build_option_values_form
        @product.variant_kind_option_types.each do |option_type|
          @variant.option_values.build(option_type: option_type) if @variant.option_values.find_by(option_type_id: option_type.id).blank?
        end
      end

      # construct option values base on name & create new option value when not exist.
      # then set to variant.
      def build_option_values
        option_values = permitted_resource_params.delete(:option_values_attributes).to_h.values
        return if option_values.blank?

        @object.option_values = option_values.each_with_object([]) do |option_value, new_option_values|
          option_value_name = validated_option_value_name(option_value[:name], option_value[:option_type_id])
          next if option_value_name.blank?

          option_type = @product.option_types.find(option_value[:option_type_id])
          existing_option_value = option_type.option_values.find_or_create_by(name: option_value_name)

          new_option_values << existing_option_value
        end
      end

      def build_guest_info
        bit_fields = SpreeCmCommissioner::KycBitwise::BIT_FIELDS.keys

        if permitted_resource_params[:use_product_kyc] == '1'
          permitted_resource_params[:kyc] = nil
        else
          @kyc_result = calculate_kyc_value(params[:variant])
          permitted_resource_params[:kyc] = @kyc_result
        end
        # remove these fields from params to prevent unknown attribute error
        bit_fields.each { |field| params.require(:variant).delete(field) }
        params.require(:variant).delete(:use_product_kyc)
      end

      # some option value name changed after validate.
      def validated_option_value_name(name, option_type_id)
        return nil if name.blank?

        option_value = Spree::OptionValue.new(name: name, option_type_id: option_type_id)
        option_value.validate
        option_value.name
      end
    end
  end
end

unless Spree::Admin::VariantsController.ancestors.include?(SpreeCmCommissioner::Admin::VariantsControllerDecorator)
  Spree::Admin::VariantsController.prepend(SpreeCmCommissioner::Admin::VariantsControllerDecorator)
end
