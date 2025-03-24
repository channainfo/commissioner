module SpreeCmCommissioner
  class InventoryItemSyncer < BaseInteractor
    delegate :inventory_ids, :quantities, to: :context

    def call
      inventory_items = fetch_inventory_items
      inventory_items.each_with_index do |inventory_item, index|
        manifest_unstock(inventory_item, quantities[index])
      end
    end

    private

    def fetch_inventory_items
      InventoryItem.where(id: inventory_ids)
    end

    def manifest_unstock(inventory_item, quantity)
      inventory_item.update!(quantity_available: inventory_item.quantity_available - quantity)
    end
  end
end
