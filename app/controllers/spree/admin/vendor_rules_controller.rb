module Spree
  module Admin
    class VendorRulesController < Spree::Admin::ResourceController
      before_action :load_vendor
      
      # @overrided
      def load_vendor
        @vendor ||= Spree::Vendor.find_by(slug: params[:vendor_id])
        @vendor ||= Spree::Vendor.find_by(id: params[:vendor_id])
      end

      # @overrided
      def index
        @vendor_kind_option_types = @vendor.vendor_kind_option_types
      end

      # @overrided
      def permitted_resource_params
        option_values = []
        selected_vendor_kind_option_value_ids = params[object_name]['selected_vendor_kind_option_value_ids']

        selected_vendor_kind_option_value_ids.each do | option_value_id |
          option_value_id = option_value_id.to_i 

          unless option_value_id == 0 
            option_value = Spree::OptionValue.find(option_value_id)
            option_values << option_value unless option_value.nil?
          end
        end

        { 'vendor_kind_option_values': option_values }
      end

      # @overrided
      def model_class
        Spree::OptionType
      end

      # @overrided
      def object_name
        'spree_option_type'
      end

      # @overrided
      def collection_url(options = {})
        admin_vendor_vendor_rules_index_url(options)
      end
    end
  end
end