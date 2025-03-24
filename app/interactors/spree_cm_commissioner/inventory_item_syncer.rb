module SpreeCmCommissioner
  class InventoryItemSyncer < BaseInteractor
    delegate :inventory_ids, :quantities, to: :context

    def call
      inventory_items.each_with_index do |inventory_item, index|
        adjust_quantity_available(inventory_item, quantities[index])
      end
    end

    private

    def adjust_quantity_available(inventory_item, quantity)
      inventory_item.with_lock do
        inventory_item.update!(quantity_available: inventory_item.quantity_available + quantity)
      end
    end

    def inventory_items
      InventoryItem.where(id: inventory_ids)
    end
  end
end
