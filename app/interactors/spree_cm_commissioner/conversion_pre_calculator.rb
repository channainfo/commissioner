module SpreeCmCommissioner
  class ConversionPreCalculator < BaseInteractor
    delegate :product_taxon, to: :context

    def call
      product_taxon.update(
        total_count: total_count,
        revenue: revenue
      )
    end

    def total_count
      product_taxon.complete_line_items.pluck(:quantity).compact.sum
    end

    def revenue
      product_taxon.complete_line_items.map(&:amount).compact.sum
    end
  end
end
