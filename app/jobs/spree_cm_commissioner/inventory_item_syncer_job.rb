module SpreeCmCommissioner
  class InventoryItemSyncerJob < ApplicationUniqueJob
    def perform(inventory_ids:, quantities:)
      InventoryItemSyncer.call(inventory_ids:, quantities:)
    end
  end
end
