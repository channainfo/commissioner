module SpreeCmCommissioner
  module Stock
    class PermanentInventoryItemsGenerator < BaseInteractor
      delegate :variant_ids, to: :context

      def variants_per_batch = 1000

      def call
        variants.in_batches(of: variants_per_batch) do |batch|
          generate_inventory_items_for_batch(batch)
        end
      end

      private

      def generate_inventory_items_for_batch(batch)
        total_on_hand_by_variant = total_on_hand_for(batch)
        batch.each do |variant|
          count_on_hand = total_on_hand_by_variant[variant.id] || 0
          generate_inventory_items_for_variant(variant, count_on_hand)
        end
      end

      def generate_inventory_items_for_variant(variant, count_on_hand)
        inventory_dates_for(variant).each do |inventory_date|
          next if inventory_exist?(variant, inventory_date)

          create_inventory_item(variant, inventory_date, count_on_hand)
        end
      end

      def inventory_dates_for(variant)
        start_date = Time.zone.tomorrow
        end_date = Time.zone.today + variant.pre_inventory_days

        (start_date..end_date)
      end

      def inventory_exist?(variant, inventory_date)
        variant.inventory_items.exists?(inventory_date: inventory_date)
      end

      def create_inventory_item(variant, inventory_date, count_on_hand)
        variant.inventory_items.create!(
          inventory_date: inventory_date,
          quantity_available: count_on_hand,
          max_capacity: count_on_hand,
          product_type: variant.product_type
        )
      end

      # Returns a hash: { variant_id => total_on_hand, ... }
      def total_on_hand_for(variants)
        variant_ids = variants.pluck(:id)

        Spree::StockItem
          .joins(:stock_location)
          .where(deleted_at: nil, variant_id: variant_ids)
          .where(spree_stock_locations: { active: true })
          .group(:variant_id)
          .sum(:count_on_hand)
      end

      def variants
        scope = Spree::Variant.active.with_permanent_stock.where(is_master: false).includes(:product)
        scope = scope.where(id: variant_ids) if variant_ids.present?
        scope
      end
    end
  end
end
