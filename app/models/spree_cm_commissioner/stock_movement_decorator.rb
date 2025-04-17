module SpreeCmCommissioner
  module StockMovementDecorator
    def self.prepended(base)
      base.after_create :adjust_inventory_items, if: -> { stock_item.should_track_inventory? }
    end

    def adjust_inventory_items
      if !variant.permanent_stock? && !variant.default_inventory_item_exist?
        variant.create_default_non_permanent_inventory_item!
      else
        adjust_existing_inventory_items!
      end
    end

    private

    def should_create_default_non_permanent_inventory_item?
      return false if variant.permanent_stock?
      return false if variant.inventory_items.exists?(inventory_date: nil)

      true
    end

    def adjust_existing_inventory_items!
      variant.inventory_items.active.find_each(batch_size: 100) do |inventory_item|
        inventory_item.adjust_quantity!(quantity)
      end
    end
  end
end

unless Spree::StockMovement.included_modules.include?(SpreeCmCommissioner::StockMovementDecorator)
  Spree::StockMovement.prepend(SpreeCmCommissioner::StockMovementDecorator)
end
