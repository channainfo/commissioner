module Spree
  module Admin
    class MetafieldsController < Spree::Admin::ResourceController
      before_action :load_resource, :laod_metafields

      update.fails :flash_error
      create.fails :flash_error

      def update_metafields
        scope = params[:scope].to_sym

        SpreeCmCommissioner::Metafields::ProductMetadataService.new(update_metafield_params)
                                                               .update_metafields(scope)

        redirect_back fallback_location: collection_url(scope)
      end

      def remove_metafield
        scope = params[:scope].to_sym

        SpreeCmCommissioner::Metafields::ProductMetadataService.new(params)
                                                               .remove_metafield_by_key(params[:key], scope)

        redirect_back fallback_location: collection_url
      end

      def flash_error
        flash[:error] = @object.errors.full_messages.join(', ')
      end

      private

      def update_metafield_params
        guests_array = params[:metadata][:guests].values

        params[:metadata][:guests] = guests_array

        params.permit(:id, metadata: { guests: [:key, :type, { options: [] }] })
      end

      # @overrided
      def collection_url(options = {})
        edit_metafields_admin_product_url(@product, options)
      end

      def model_class
        Spree::Product
      end

      def load_resource
        @product ||= Spree::Product.find_by!(slug: params[:id])
        @object ||= @product
      end

      def laod_metafields
        key_param = params[:key] || 'guests'

        @public_metafields = filter_metadata(@product.public_metadata, key_param)
        @private_metafields = filter_metadata(@product.private_metadata, key_param)
      end

      def filter_metadata(metadata, key)
        return metadata if key == 'guests' || metadata[key].blank?

        { key => metadata[key] }
      end
    end
  end
end
