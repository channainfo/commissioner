class GenerateDefaultInventoryItemForNonPermanentStockVariant < ActiveRecord::Migration[7.0]
  def change
    Spree::Variant.active.with_non_permanent_stock.find_each do |variant|
      total_purchases = variant.complete_line_items.sum(:quantity).to_i || 0
      max_capacity = variant.total_on_hand || 0
      quantity_available = [max_capacity - total_purchases, 0].max

      variant.create_default_non_permanent_inventory_item!(
        max_capacity: max_capacity,
        quantity_available: quantity_available
      )
    end
  end
end
