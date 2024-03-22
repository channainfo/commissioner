class GenerateDefaultValueForPriceableInSpreePrices < ActiveRecord::Migration[7.0]
  def change
    if column_exists?(:spree_prices, :variant_id)
      Spree::Price.unscoped.update_all("priceable_id = spree_prices.variant_id, priceable_type = 'Spree::Variant'")
    end
  end
end
