module SpreeCmCommissioner
  module ReviewDecorator
    def self.prepended(base)
      base.has_many :images, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::ReviewImage'
      base.has_many :taxon_reviews, class_name: 'SpreeCmCommissioner::TaxonReview', dependent: :destroy
      base.accepts_nested_attributes_for :taxon_reviews, allow_destroy: true
    end
  end
end

Spree::Review.prepend(SpreeCmCommissioner::ReviewDecorator) unless Spree::Review.included_modules.include?(SpreeCmCommissioner::ReviewDecorator)
