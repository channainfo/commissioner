module SpreeCmCommissioner
  module StockItemDecorator
    def self.prepended(base)
      base.has_one :vendor, through: :variant
      base.after_save :update_vendor_total_inventory, if: :saved_change_to_count_on_hand?

      base.after_commit :create_inventory_items, on: :create
      base.after_commit :adjust_inventory_items_async, on: :destroy
    end

    def update_vendor_total_inventory
      SpreeCmCommissioner::VendorJob.perform_later(vendor.id) if vendor.present?
    end

    private

    def create_inventory_items
      if variant.permanent_stock?
        SpreeCmCommissioner::Stock::PermanentInventoryItemsGeneratorJob.perform_later(variant_ids: [variant.id])
      else
        variant.create_default_non_permanent_inventory_item! unless variant.default_inventory_item_exist?
      end
    end

    # When admin delete stock item, it will deduct stock from inventory item
    def adjust_inventory_items_async
      SpreeCmCommissioner::Stock::InventoryItemsAdjusterJob.perform_later(variant_id: variant_id, quantity: -count_on_hand)
    end
  end
end

unless Spree::StockItem.included_modules.include?(SpreeCmCommissioner::StockItemDecorator)
  Spree::StockItem.prepend(SpreeCmCommissioner::StockItemDecorator)
end
