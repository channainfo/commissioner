module SpreeCmCommissioner
  class InventoryItemSyncerJob < ApplicationUniqueJob
    def perform(inventory_id_and_quantities:, line_item_ids:)
      InventoryItemSyncer.call(inventory_id_and_quantities:)

      CmAppLogger.log(label: 'InventoryItemSyncerJob',
                      data: { inventory_id_and_quantities: inventory_id_and_quantities.as_json, line_item_ids: line_item_ids }
                     )
    end
  end
end
