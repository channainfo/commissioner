module SpreeCmCommissioner
  module TaxonomyDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::TaxonKind

      def base.businesses
        ActiveRecord::Base.connected_to(role: :writing) do
          Spree::Taxonomy.find_or_create_by(name: 'Businesses', kind: 'category', store: Spree::Store.default)
        end
      end
    end
  end
end

unless Spree::Taxonomy.included_modules.include?(SpreeCmCommissioner::TaxonomyDecorator)
  Spree::Taxonomy.prepend(SpreeCmCommissioner::TaxonomyDecorator)
end
