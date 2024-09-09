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

    def product_aggregators
      select_fields = [
        'product_id',
        'SUM(total_count) AS total_tickets',
        'COUNT(*) AS total_items'
      ]

      Spree::Classification
        .select(select_fields)
        .joins(taxon: :parent)
        .where(parent: { id: taxon_id })
        .group('product_id')
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
