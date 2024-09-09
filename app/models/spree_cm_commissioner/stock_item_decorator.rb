module SpreeCmCommissioner
  module StockItemDecorator
    def self.prepended(base)
      base.has_one :vendor, through: :variant
      base.after_save :update_vendor_total_inventory, if: :saved_change_to_count_on_hand?
    end

    def update_vendor_total_inventory
      SpreeCmCommissioner::VendorJob.perform_later(vendor.id) if vendor.present?
    end
  end
end

unless Spree::StockItem.included_modules.include?(SpreeCmCommissioner::StockItemDecorator)
  Spree::StockItem.prepend(SpreeCmCommissioner::StockItemDecorator)
end
