namespace :spree_cm_commissioner do
  desc 'Generate inventory items for all variants.'
  task generate_inventory_items: :environment do
    SpreeCmCommissioner::InventoryItemGeneratorJob.perform_now
  end
end
