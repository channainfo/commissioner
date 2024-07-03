module SpreeCmCommissioner
  class TaxonStarRating < Base
    validates :star, presence: true
    enum kind: { sub_rating: 0, selection: 1 }
    belongs_to :taxon, class_name: 'Spree::Taxon'
    belongs_to :product, class_name: 'Spree::Product'
  end
end
