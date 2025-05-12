# recommend to be used in schedule.yml & schedule run it everyday
namespace :spree_cm_commissioner do
  desc 'Generate inventory items for permanent_stock variants.'
  task generate_inventory_items: :environment do
    SpreeCmCommissioner::Stock::PermanentInventoryItemsGeneratorJob.perform_now
  end
end
