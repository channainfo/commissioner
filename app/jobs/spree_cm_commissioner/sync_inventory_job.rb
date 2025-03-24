module SpreeCmCommissioner
  class SyncInventoryJob < ApplicationUniqueJob
    def perform(inventory_ids, quantity)
      InventoryUnit.where(id: inventory_ids).each do |inventory_unit|
        update_inventory_unit(inventory_unit, quantity)
      end
    end

    private

    def update_inventory_unit(inventory_unit, quantity)
      inventory_unit.update!(quantity_available: inventory_unit.quantity_available - quantity)
    end
  end
end
