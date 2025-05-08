module SpreeCmCommissioner
  class InventoryItemSyncerJob < ApplicationUniqueJob
    def perform(inventory_id_and_quantities:, line_item_ids:)
      CmAppLogger.log(label: 'InventoryItemSyncerJob',
                      data: { inventory_id_and_quantities: inventory_id_and_quantities, line_item_ids: line_item_ids }
                     ) do
        InventoryItemSyncer.call(inventory_id_and_quantities: inventory_id_and_quantities)
      end
    end
  end
end
