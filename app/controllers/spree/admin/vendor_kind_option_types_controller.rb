module Spree
  module Admin
    class VendorKindOptionTypesController < Spree::Admin::ResourceController
      before_action :load_resource
      
      # @overrided
      def load_resource
        @vendor ||= Spree::Vendor.find_by(slug: params[:vendor_id])
        @vendor ||= Spree::Vendor.find_by(id: params[:vendor_id])
        @object ||= @vendor
      end

      # @overrided
      def index
        @vendor_kind_option_types = @vendor.vendor_kind_option_types
      end

      # @overrided
      def permitted_resource_params
        option_values = []
        selected_option_value_vendors_ids = params[object_name]['selected_option_value_vendors_ids']

        selected_option_value_vendors_ids.each do | option_value_id |
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
        Spree::Vendor
      end

      # @overrided
      def object_name
        'vendor'
      end

      # @overrided
      def collection_url(options = {})
        admin_vendor_vendor_rules_index_url(options)
      end
    end
  end
end
