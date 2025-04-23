module SpreeCmCommissioner
  module RedisStock
    class InventoryChecker
      def initialize(line_item_ids)
        @line_item_ids = line_item_ids
      end

      def can_supply_all?
        return false if inventory_items.empty? || @line_item_ids.blank?

        inventory_items.all? do |inventory_item|
          inventory_item[:quantity_available] >= inventory_item[:purchase_quantity]
        end
      end

      private

      def inventory_items
        @inventory_items ||= SpreeCmCommissioner::RedisStock::InventoryKeyQuantityBuilder.new(@line_item_ids).call
      end
    end
  end
end
