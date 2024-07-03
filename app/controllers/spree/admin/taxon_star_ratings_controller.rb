module Spree
  module Admin
    class TaxonStarRatingsController < Spree::Admin::ResourceController
      before_action :load_resource

      def create
        context = SpreeCmCommissioner::StarRatingModifier.call(params: params, product: @product)
        return unless context.success?

        redirect_to admin_product_taxon_star_ratings_path(kind: params[:kind])
      end

      private

      def model_class
        SpreeCmCommissioner::TaxonStarRating
      end

      def object_name
        'spree_cm_commissioner_taxon_star_rating'
      end

      def load_resource
        @product ||= Spree::Product.find_by!(slug: params[:product_id])
        @taxon_star_ratings ||= @product.taxon_star_ratings.where(kind: params[:kind]).all
        @group_taxon_star_ratings ||= @taxon_star_ratings.group_by(&:star)
        @review_type_taxons = Spree::Taxon.where(kind: :review).first.children
      end
    end
  end
end
