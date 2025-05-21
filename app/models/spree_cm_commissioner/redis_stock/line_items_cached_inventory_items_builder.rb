module SpreeCmCommissioner
  module RedisStock
    class LineItemsCachedInventoryItemsBuilder
      attr_reader :line_item_ids

      def initialize(line_item_ids:)
        @line_item_ids = line_item_ids
      end

      # return list of inventory items group by :line_item_id:
      # {
      #   1: [ CachedInventoryItem(...), CachedInventoryItem(...) ],
      #   2: [ CachedInventoryItem(...), CachedInventoryItem(...) ],
      # }
      def call
        cached_inventory_items.group_by do |cached_inventory_item|
          line_item = line_items.find { |item| item.variant_id == cached_inventory_item.variant_id }
          line_item.id
        end
      end

      def cached_inventory_items
        @cached_inventory_items ||= SpreeCmCommissioner::RedisStock::CachedInventoryItemsBuilder.new(inventory_items)
                                                                                                .call
      end

      def inventory_items
        @inventory_items ||= line_items.flat_map(&:inventory_items)
      end

      def line_items
        @line_items ||= Spree::LineItem.where(id: line_item_ids).includes(:inventory_items)
      end
    end
  end
end
