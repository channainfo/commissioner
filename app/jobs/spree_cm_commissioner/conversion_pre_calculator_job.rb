module SpreeCmCommissioner
  class ConversionPreCalculatorJob < ApplicationUniqueJob
    queue_as :default

    def perform(product_id)
      product = Spree::Product.find(product_id)
      product.classification_ids.each do |classification_id|
        SpreeCmCommissioner::ConversionPreCalculator.call(product_taxon: Spree::Classification.find(classification_id))
      end
    end
  end
end
