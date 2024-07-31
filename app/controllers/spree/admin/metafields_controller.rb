module Spree
  module Admin
    class MetafieldsController < Spree::Admin::ResourceController
      before_action :load_resource

      update.fails :flash_error
      create.fails :flash_error

      def update_private_metafields
        byebug
        @product = Spree::Product.find_by!(slug: params[:id])

        key = params[:key]
        type = params[:type]
        value = params[:value]

        @product.set_private_metafields()
      end

      # @overrided
      def permitted_resource_params
        metafield_result = calculate_metafield_value(params[:product])

        params.require(:product).permit(:allowed_upload_later).merge(metafield: metafield_result)
      end

      def flash_error
        flash[:error] = @object.errors.full_messages.join(', ')
      end

      # @overrided
      def collection_url
        edit_metafields_admin_product_url
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
