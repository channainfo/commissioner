module SpreeCmCommissioner
  module TaxonomyDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::TaxonomyKind

      def base.place
        Spree::Taxonomy.find_or_create_by(name: 'Place', kind: 'transit', store: Spree::Store.default)
      end
    end
  end
end

unless Spree::Taxonomy.included_modules.include?(SpreeCmCommissioner::TaxonomyDecorator)
  Spree::Taxonomy.prepend(SpreeCmCommissioner::TaxonomyDecorator)
end
