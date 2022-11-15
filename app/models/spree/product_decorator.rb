module Spree
  module ProductDecorator
    def self.prepended(base)
      base.has_many :prices_including_master, -> { order('spree_variants.position, spree_variants.id, currency') }, source: :prices, through: :variants_including_master
      base.scope  :min_price, -> (vendor) { joins(:prices_including_master).where(vendor_id: vendor.id).minimum('spree_prices.price').to_f }
      base.scope  :max_price, -> (vendor) { joins(:prices_including_master).where(vendor_id: vendor.id).maximum('spree_prices.price').to_f }
    end
  end
end

Spree::Product.prepend(Spree::ProductDecorator)