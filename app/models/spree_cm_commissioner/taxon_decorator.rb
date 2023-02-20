module SpreeCmCommissioner
  module TaxonDecorator
    def self.prepended(base)
      base.has_one :category_icon, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::TaxonCategoryIcon'

      base.validates_associated :category_icon
    end
  end
end

Spree::Taxon.prepend(SpreeCmCommissioner::TaxonDecorator) unless Spree::Taxon.included_modules.include?(SpreeCmCommissioner::TaxonDecorator)
