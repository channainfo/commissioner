module SpreeCmCommissioner
  class TripInventoryQuery
    attr_reader :variant_ids, :date, :vendor_id

    def initialize(variant_ids:, date:, vendor_id: nil)
      @variant_ids = variant_ids
      @date = date
      @vendor_id = vendor_id
    end

    def call
      Spree::Variant
        .joins(:line_items)
        .joins(line_items: :order)
        .joins('INNER JOIN cm_trips ON cm_trips.variant_id = spree_variants.id')
        .joins('INNER JOIN cm_vehicles ON cm_vehicles.id = cm_trips.vehicle_id')
        .where(id: variant_ids)
        .where(spree_orders: { state: 'complete' })
        .where(spree_line_items: { date: date })
        .group('spree_variants.id', 'cm_vehicles.number_of_seats')
        .select(
          'spree_variants.id',
          'cm_vehicles.number_of_seats AS total_seats',
          'SUM(spree_line_items.quantity) AS total_sold'
        )
    end
  end
end
