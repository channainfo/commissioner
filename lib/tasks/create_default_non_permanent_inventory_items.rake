# recommend to be used in schedule.yml & manually access in /sidekiq/cron
namespace :spree_cm_commissioner do
  desc 'Create default inventory items for non-permanent stock products'
  task create_default_non_permanent_inventory_items: :environment do
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
