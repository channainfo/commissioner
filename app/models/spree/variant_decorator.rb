 module Spree
  module VariantDecorator
    def self.prepended(base)
      base.after_commit :update_vendor_price
    end

    private
    def update_vendor_price
      if product_type&.name == 'Property'
        vendor.update(min_price: price) if price < vendor.min_price
        vendor.update(max_price: price) if price > vendor.max_price
      end
    end
  end
end

Spree::Variant.prepend(Spree::VariantDecorator)