module Spree
  module Admin
    class StockManagementsController < Spree::Admin::ResourceController
      skip_before_action :load_resource

      before_action :load_parent

      helper_method :inventory_item_message

      def load_parent
        @product = Spree::Product.find_by(slug: params[:product_id])
      end

      def index
        @variants = @product.variants.includes(:images, stock_items: :stock_location, option_values: :option_type)
        @variants = [@product.master] if @variants.empty?
        @stock_locations = (@variants.flat_map(&:stock_locations) + @product.vendor.stock_locations).uniq

        load_inventories unless @product.permanent_stock?
      end

      def calendar
        @year = params[:year].present? ? params[:year].to_i : Time.zone.today.year

        from_date = Date.new(@year, 1, 1).beginning_of_year
        to_date = Date.new(@year, 1, 1).end_of_year

        @inventory_items = @product.inventory_items.includes(:variant).where(inventory_date: from_date..to_date).to_a
        @cached_inventory_items = ::SpreeCmCommissioner::RedisStock::CachedInventoryItemsBuilder.new(@inventory_items)
                                                                                                .call
                                                                                                .index_by(&:inventory_item_id)
        @events = SpreeCmCommissioner::CalendarEvent.from_inventory_items(@inventory_items)
      end

      def inventory_item_message(inventory_item, cached_inventory_item)
        synced = inventory_item.quantity_available == cached_inventory_item.quantity_available

        if synced
          "Synced: Quantity available matches in both DB and Redis (#{cached_inventory_item.quantity_available})."
        else
          "Out of sync: Redis shows #{cached_inventory_item.quantity_available} available, which doesn't match the database."
        end
      end

      private

      def load_inventories
        @inventory_items = @product.inventory_items.group_by { |item| item.variant.id }
        @cached_inventory_items = ::SpreeCmCommissioner::RedisStock::CachedInventoryItemsBuilder.new(@product.inventory_items)
                                                                                                .call
                                                                                                .index_by(&:inventory_item_id)
        @reserved_stocks = Spree::LineItem
                           .complete
                           .where(variant_id: @variants.pluck(:id))
                           .group('spree_line_items.variant_id')
                           .sum(:quantity)
      end

      def model_class
        Spree::StockItem
      end
    end
  end
end
