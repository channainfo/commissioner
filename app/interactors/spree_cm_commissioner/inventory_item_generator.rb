module SpreeCmCommissioner
  class InventoryItemGenerator < BaseInteractor
    delegate :variant_ids, to: :context

    def call
      variants.in_batches(of: 1000) do |batch|
        process_batch(batch)
      end
    end

    private

    def process_batch(batch)
      # Compute total_on_hand for all variants in the batch
      total_on_hand = calculate_total_on_hand(batch)

      # Process each variant in the batch
      batch.each do |variant|
        next if variant.delivery_required? # Skip if delivery is required (e.g., ecommerce product_type)

        generate_inventory_items(variant, total_on_hand[variant.id])
      end
    end

    def generate_inventory_items(variant, max_capacity)
      # permanent_stock? is true for accommodation and transit
      if variant.permanent_stock?
        inventory_date_range = Date.tomorrow..Time.zone.today + variant.pre_inventory_days
        inventory_date_range.each do |inventory_date|
          create_inventory_item(variant:, inventory_date:, max_capacity:)
        end
      else
        create_inventory_item(variant: variant, inventory_date: nil, max_capacity: max_capacity)
      end
    end

    def create_inventory_item(variant:, inventory_date:, max_capacity:)
      return if variant.inventory_items.exists?(inventory_date: inventory_date)

      quantity_available = max_capacity - (variant.reserved_quantity || 0)

      InventoryItem.create!(
        variant_id: variant.id,
        inventory_date: inventory_date,
        quantity_available: quantity_available,
        max_capacity: max_capacity,
        product_type: variant.product_type
      )
    end

    # Example: {640=>10, 641=>5, 642=>3}
    def calculate_total_on_hand(batch)
      Spree::StockItem
        .joins(:stock_location)
        .where(deleted_at: nil, variant_id: batch.pluck(:id))
        .where(spree_stock_locations: { active: true })
        .group(:variant_id)
        .sum(:count_on_hand)
    end

    def variants
      @variants ||= scope.joins("LEFT JOIN spree_line_items l ON l.variant_id = spree_variants.id")
                         .joins("LEFT JOIN spree_orders o ON o.id = l.order_id AND o.completed_at IS NOT NULL AND o.state != 'canceled'")
                         .select('spree_variants.*, COALESCE(SUM(l.quantity), 0) AS reserved_quantity')
                         .group('spree_variants.id')
                         .includes(:product)
    end

    def scope
      scope = Spree::Variant.active.where(is_master: false)
      scope = scope.where(id: variant_ids) if variant_ids.present?
      scope
    end
  end
end
