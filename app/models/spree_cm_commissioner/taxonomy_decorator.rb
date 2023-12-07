module SpreeCmCommissioner
  module TaxonomyDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::TaxonomyKind
    end
  end
end

Spree::Taxonomy.prepend(SpreeCmCommissioner::TaxonomyDecorator) unless Spree::Taxonomy.included_modules.include?(SpreeCmCommissioner::TaxonomyDecorator)


    