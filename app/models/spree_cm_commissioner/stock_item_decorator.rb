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
      SpreeCmCommissioner::Stock::InventoryItemsGeneratorJob.perform_later(variant_id: variant.id)
    end

    # When admin delete stock item, it will deduct stock from inventory item
    def adjust_inventory_items_async
      params = { variant_id: variant.id, quantity: -count_on_hand }
      CmAppLogger.log(label: "#{self.class.name}:after_destroy#adjust_inventory_items_async", data: params) do
        SpreeCmCommissioner::Stock::InventoryItemsAdjusterJob.perform_later(**params)
      end
    end
  end
end

unless Spree::StockItem.included_modules.include?(SpreeCmCommissioner::StockItemDecorator)
  Spree::StockItem.prepend(SpreeCmCommissioner::StockItemDecorator)
end
