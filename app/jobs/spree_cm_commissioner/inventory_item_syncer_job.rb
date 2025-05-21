module SpreeCmCommissioner
  class InventoryItemSyncerJob < ApplicationUniqueJob
    def perform(inventory_id_and_quantities:)
      InventoryItemSyncer.call(inventory_id_and_quantities:)
    end
  end
end
