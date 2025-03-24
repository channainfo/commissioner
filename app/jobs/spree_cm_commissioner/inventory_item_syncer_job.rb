module SpreeCmCommissioner
  class InventoryItemSyncerJob < ApplicationUniqueJob
    def perform(inventory_ids, quantities)
      InventoryItemSyncer.call(inventory_ids: inventory_ids, quantities: quantities)
    end
  end
end
