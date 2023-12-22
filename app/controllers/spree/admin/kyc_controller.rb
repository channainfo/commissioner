module Spree
  module Admin
    class KycController < Spree::Admin::ResourceController
      before_action :load_resource

      include SpreeCmCommissioner::Admin::KycableHelper

      # @overrided
      def permitted_resource_params
        result = calculate_kyc_value(params[:product])

        { kyc: result }
      end

      # @overrided
      def collection_url(options = {})
        edit_kyc_admin_product_url(options)
      end

      def model_class
        Spree::Product
      end

      def load_resource
        @product ||= Spree::Product.find_by!(slug: params[:id])
        @object ||= @product
      end
    end
  end
end
