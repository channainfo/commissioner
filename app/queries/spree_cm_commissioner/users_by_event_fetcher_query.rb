module SpreeCmCommissioner
  class UsersByEventFetcherQuery
    attr_reader :taxon_id

    def initialize(taxon_id)
      @taxon_id = taxon_id
    end

    def call
      classifications = Spree::Classification.where(taxon_id: @taxon_id)
      product_ids = classifications.pluck(:product_id)
      Spree::User.joins(orders: { line_items: :variant })
                 .where(spree_orders: { state: 'complete' })
                 .where(spree_variants: { product_id: product_ids })
                 .distinct
    end
  end
end
