module SpreeCmCommissioner
  class InventoryItemSyncer < BaseInteractor
    # inventory_id_and_quantities = [{ inventory_id: inventory_item1.id, quantity: 5 } ]
    delegate :inventory_id_and_quantities, to: :context

    def call
      ActiveRecord::Base.transaction do
        inventory_items.each do |inventory_item|
          quantity = inventory_id_and_quantities.find { |item| item[:inventory_id] == inventory_item.id }&.dig(:quantity) || 0
          adjust_quantity_available(inventory_item, quantity)
        end
      end
    end

    private

    def adjust_quantity_available(inventory_item, quantity)
      inventory_item.update!(quantity_available: inventory_item.quantity_available + quantity)
    end

    def inventory_items
      @inventory_items ||= InventoryItem.where(id: inventory_id_and_quantities.pluck(:inventory_id))
    end
  end
end
