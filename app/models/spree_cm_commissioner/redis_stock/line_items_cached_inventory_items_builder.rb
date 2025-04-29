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
        @inventory_items ||= line_items.flat_map do |line_item|
          # TODO: N+1, we could fix but have a product_type in line item
          # then include inventory_items in line item directly #2581
          scope = line_item.inventory_items
          scope = scope.where(inventory_date: line_item.date_range) if line_item.permanent_stock?
          scope
        end
      end

      def line_items
        @line_items ||= Spree::LineItem.where(id: line_item_ids).includes(variant: %i[product])
      end
    end
  end
end
