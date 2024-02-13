module SpreeCmCommissioner
  class EventTicketAggregatorQuery
    attr_reader :taxon_id, :refreshed

    # taxon_id:, refreshed: false
    def initialize(taxon_id:, refreshed: false)
      @taxon_id = taxon_id
      @refreshed = refreshed
    end

    def call
      cache_key = "event-ticket-aggregator-query-#{taxon_id}"
      Rails.cache.delete(cache_key) if refreshed

      value = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
        product_aggregators || []
      end

      SpreeCmCommissioner::EventTicketAggregator.new(
        id: taxon_id,
        value: value
      )
    end

    # SELECT
    #     spree_products.id as product_id,
    #     SUM(spree_line_items.quantity) AS total_ticket,
    #     COUNT(*) AS total_items
    # FROM spree_products
    # INNER JOIN spree_variants ON spree_products.id = spree_variants.product_id
    # INNER JOIN spree_line_items ON spree_variants.id = spree_line_items.variant_id
    # INNER JOIN spree_orders ON spree_orders.id = spree_line_items.order_id
    # INNER JOIN spree_products_taxons ON spree_products.id = spree_products_taxons.product_id
    # WHERE
    #     spree_orders.state = 'complete' AND
    #     spree_products_taxons.taxon_id = 18
    # GROUP BY spree_products.id;

    def product_aggregators
      select_fields = [
        'spree_products.id as product_id',
        'SUM(spree_line_items.quantity) AS total_tickets',
        'COUNT(*) AS total_items'
      ]

      Spree::Product
        .select(select_fields)
        .joins('INNER JOIN spree_variants ON spree_products.id = spree_variants.product_id')
        .joins('LEFT JOIN spree_line_items ON spree_variants.id = spree_line_items.variant_id')
        .joins('INNER JOIN spree_orders ON spree_orders.id = spree_line_items.order_id')
        .joins('INNER JOIN spree_products_taxons ON spree_products.id = spree_products_taxons.product_id')
        .joins('INNER JOIN spree_taxons ON spree_taxons.id = spree_products_taxons.taxon_id')
        .where(spree_orders: { state: 'complete' }, spree_taxons: { parent_id: taxon_id })
        .group('spree_products.id')
        .map do |record|
          record.slice(
            :product_id,
            :total_tickets,
            :total_items
          )
        end
    end
  end
end
