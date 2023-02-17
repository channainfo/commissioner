module Spree
  module Admin
    class MasterVariantController < Spree::Admin::ResourceController
      before_action :load_resource

      # @overrided
      def load_resource
        @product ||= Spree::Product.find_by(slug: params[:product_id])
        @object ||= @product.master
      end

      # @overrided
      def index
        @product_kind_option_types = @product.product_kind_option_types
      end

      # @overrided
      def permitted_resource_params
        option_values = []
        selected_option_value_ids = params[object_name]['selected_option_value_ids']

        selected_option_value_ids.each do |option_value_id|
          option_value_id = option_value_id.to_i

          unless option_value_id.zero?
            option_value = Spree::OptionValue.find(option_value_id)
            option_values << option_value unless option_value.nil?
          end
        end

        { option_values: option_values }
      end

      # @overrided
      def model_class
        Spree::Variant
      end

      # @overrided
      def object_name
        'variant'
      end

      # @overrided
      def collection_url(options = {})
        admin_product_master_variant_index_url(options)
      end
    end
  end
end
