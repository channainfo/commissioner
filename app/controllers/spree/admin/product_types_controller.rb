module Spree
  module Admin
    class ProductTypesController < Spree::Admin::ResourceController
      # @overrided
      def collection
        @collection ||= SpreeCmCommissioner::ProductType.unscoped.all
      end

      # @overrided
      def model_class
        SpreeCmCommissioner::ProductType
      end

      # @overrided
      def object_name
        'spree_cm_commissioner_product_type'
      end

      # @overrided
      def collection_url(options = {})
        admin_product_types_url(options)
      end
    end
  end
end
