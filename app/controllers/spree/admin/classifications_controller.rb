module Spree
  module Admin
    class ClassificationsController < Spree::Admin::ResourceController
      before_action :load_taxon_and_products

      def recalculate_conversions
        @taxon.products.each do |product|
          SpreeCmCommissioner::ConversionPreCalculatorJob.perform_later(product.id)
        end

        flash[:success] = Spree.t('recalculate_products')
        redirect_to collection_url
      end

      private

      def edit_object_url(product, options = {})
        classification = @taxon.classifications.find_by(product_id: product.id)
        edit_admin_taxonomy_taxon_classification_url(taxonomy_id: @taxonomy.id, taxon_id: @taxon.id, id: classification.id, options: options)
      end

      def object_url(product, options = {})
        classification = @taxon.classifications.find_by(product_id: product.id)
        admin_taxonomy_taxon_classification_url(taxonomy_id: @taxonomy.id, taxon_id: @taxon.id, id: classification.id, options: options)
      end

      def load_taxon_and_products
        @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.find(params[:taxon_id])
      end

      def model_class
        Spree::Classification
      end

      def collection_url
        admin_taxonomy_taxon_classifications_url(taxonomy: @taxonomy, taxon: @taxon)
      end
    end
  end
end
