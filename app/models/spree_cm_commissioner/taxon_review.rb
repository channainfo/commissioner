module SpreeCmCommissioner
  class TaxonReview < Base
    belongs_to :review, class_name: 'Spree::Review'
    belongs_to :taxon, class_name: 'Spree::Taxon'
  end
end
