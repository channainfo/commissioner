module SpreeCmCommissioner
  module Metafields
    class ProductMetadataService
      def initialize(params)
        @params = params
      end

      def product
        @product ||= Spree::Product.find_by!(slug: @params[:id])
      end

      def update_metafields(scope)
        metadata = scope == :private ? product.private_metadata || {} : product.public_metadata || {}

        filtered_guests = @params[:metadata][:guests].map(&:to_h).reject { |guest| guest[:key].blank? }

        metadata[:guests] = filtered_guests

        product.update!(scope == :private ? { private_metadata: metadata } : { public_metadata: metadata })
      end

      def remove_metafield_by_key(key, scope)
        metadata = scope == :private ? product.private_metadata || {} : product.public_metadata || {}

        return if metadata['guests'].blank?

        metadata['guests'].reject! { |guest| guest['key'] == key }
        product.update!(scope == :private ? { private_metadata: metadata } : { public_metadata: metadata })
      end
    end
  end
end
