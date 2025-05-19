module SpreeCmCommissioner
  class TripInventoryQuery
    attr_reader :variant_ids, :date, :vendor_id

    def initialize(variant_ids:, date:, vendor_id: nil)
      @variant_ids = variant_ids
      @date = date
      @vendor_id = vendor_id
    end

    def call
      result = Spree::Variant.select('spree_variants.id',
                                     'COALESCE(cm_inventory_items.max_capacity, 0) AS total_seats',
                                     'COALESCE(cm_inventory_items.quantity_available, 0) AS remaining_seats'
                                    )
                             .joins('LEFT JOIN cm_inventory_items ON cm_inventory_items.variant_id = spree_variants.id')
                             .where(cm_inventory_items: { inventory_date: date })
                             .where(spree_variants: { id: variant_ids })
                             .group('spree_variants.id',
                                    'cm_inventory_items.max_capacity',
                                    'cm_inventory_items.quantity_available'
                                   )
      result = result.where(spree_variants: { vendor_id: vendor_id }) if vendor_id.present?
      result
    end
  end
end
