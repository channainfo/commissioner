module SpreeCmCommissioner
  class InventoryItemSyncerJob < ApplicationUniqueJob
    def perform(inventory_id_and_quantities:, line_item_ids:)
      InventoryItemSyncer.call(inventory_id_and_quantities: inventory_id_and_quantities)
    rescue StandardError => e
      # Alert to Telegram Developer Group
      SpreeCmCommissioner::TelegramSyncInventoryItemExceptionSender.call(inventory_id_and_quantities: inventory_id_and_quantities,
                                                                         line_item_ids: line_item_ids,
                                                                         exception: e
                                                                        )

      # Re-raise the error to trigger Sidekiq retry
      raise e
    end
  end
end
