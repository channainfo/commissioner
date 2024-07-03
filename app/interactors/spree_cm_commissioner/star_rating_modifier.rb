module SpreeCmCommissioner
  class StarRatingModifier < BaseInteractor
    delegate :params, :product, to: :context

    def call
      remove_unselected_taxon_star_ratings
      modify_taxon_star_ratings
    end

    def modify_taxon_star_ratings
      params[:taxon_star_ratings]&.each do |object|
        taxon_id, star = object.split(',')
        product.taxon_star_ratings.build(
          taxon_id: taxon_id,
          star: star,
          kind: params[:kind]
        )
      end
      product.save
    end

    def remove_unselected_taxon_star_ratings
      product.taxon_star_ratings.where(kind: params[:kind]).destroy_all
    end
  end
end
