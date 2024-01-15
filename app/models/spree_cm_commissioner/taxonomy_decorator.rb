module SpreeCmCommissioner
  module TaxonomyDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::TaxonomyKind
    end
  end
end

unless Spree::Taxonomy.included_modules.include?(SpreeCmCommissioner::TaxonomyDecorator)
  Spree::Taxonomy.prepend(SpreeCmCommissioner::TaxonomyDecorator)
end
