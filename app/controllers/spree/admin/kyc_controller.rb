module Spree
  module Admin
    class KycController < Spree::Admin::ResourceController
      before_action :load_resource

      include SpreeCmCommissioner::Admin::KycableHelper

      update.fails :flash_error
      create.fails :flash_error

      # @overrided
      def permitted_resource_params
        kyc_result = calculate_kyc_value(params[:product])
        params.require(:product).permit(:allowed_upload_later, dynamic_kyc: %i[key label attype]).merge(kyc: kyc_result)
      end

      def remove_field
        key = params[:key]

        @product.dynamic_kyc.reject! { |field| field['key'] == key }

        if @product.save
          render json: { success: true }
        else
          render json: { success: false, errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def flash_error
        flash[:error] = @object.errors.full_messages.join(', ')
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
