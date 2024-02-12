module SpreeCmCommissioner
  class ProductsTaxonsTotalCountPreCalculatorJob < ApplicationJob
    def perform(product_taxon_id)
      product_taxon = Spree::Classification.find(product_taxon_id)

      SpreeCmCommissioner::ProductsTaxonsTotalCountPreCalculator.call(product_taxon: product_taxon)
    end
  end
end
