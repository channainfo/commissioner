module SpreeCmCommissioner
  class ProductsTaxonsTotalCountPreCalculator < BaseInteractor
    delegate :product_taxon, to: :context

    def call
      product_taxon.update(total_count: total_count)
    end

    def total_count
      product_taxon.complete_line_items.pluck(:quantity).compact.sum
    end
  end
end
