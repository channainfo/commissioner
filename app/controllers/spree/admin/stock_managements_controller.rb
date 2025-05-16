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

      def create
        result = SpreeCmCommissioner::Stock::StockMovementCreator.call(
          variant_id: params[:variant_id],
          stock_location_id: params[:stock_location_id],
          current_store: current_store,
          stock_movement_params: stock_movement_params
        )

        if result.success?
          flash[:success] = flash_message_for(result.stock_movement, :successfully_created)
        else
          flash[:error] = result.message
        end

        redirect_back fallback_location: admin_product_stock_managements_path(@product)
      end

      # POST /products/:slug/stock_managements/create_inventory_item?variant_id=:id
      def create_inventory_item
        variant = @product.variants.find(params[:variant_id])
        inventory_item = variant.create_default_non_permanent_inventory_item!

        if inventory_item.present?
          result = SpreeCmCommissioner::Stock::InventoryItemResetter.call(inventory_item: inventory_item)

          if result.success?
            flash[:success] = flash_message_for(result.inventory_item, :successfully_created)
          else
            flash[:error] = result.message
          end
        end

        redirect_back fallback_location: admin_product_stock_managements_path(@product)
      end

      # PATCH /products/:slug/stock_managements/reset_inventory_item?inventory_item_id=:id
      def reset_inventory_item
        inventory_item = @product.inventory_items.find(params[:inventory_item_id])
        result = SpreeCmCommissioner::Stock::InventoryItemResetter.call(inventory_item: inventory_item)

        if result.success?
          flash[:success] = flash_message_for(result.inventory_item, :successfully_updated)
        else
          flash[:error] = result.message
        end

        redirect_back fallback_location: admin_product_stock_managements_path(@product)
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

      # This method processes the parameters for stock movement creation.
      # Expected attributes for `stock_movement` include:
      # - :quantity (Integer): The quantity of stock to move.
      # - :action (String): The type of stock movement (e.g., "add" or "remove").
      # - :originator_id, :originator_ty (String, optional): The ID and type of the entity creating the stock movement.
      # Ensure that `permitted_stock_movement_attributes` is updated to reflect any changes.
      def stock_movement_params
        params.require(:stock_movement).permit(permitted_stock_movement_attributes)
      end
    end
  end
end
