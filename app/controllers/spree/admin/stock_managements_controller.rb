module Spree
  module Admin
    class StockManagementsController < Spree::Admin::ResourceController
      skip_before_action :load_resource

      before_action :load_parent

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
        @events = SpreeCmCommissioner::CalendarEvent.from_inventory_items(@inventory_items)
      end

      private

      def load_inventories
        @inventory_items = @product.inventory_items.group_by { |item| item.variant.id }
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
