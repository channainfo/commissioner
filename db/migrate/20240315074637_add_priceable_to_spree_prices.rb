class AddPriceableToSpreePrices < ActiveRecord::Migration[7.0]
  def self.up
    unless column_exists?(:spree_prices, :priceable_id)
      add_reference :spree_prices, :priceable, polymorphic: true
    end
  end

  def self.down
    if column_exists?(:spree_prices, :priceable_id)
      remove_reference :spree_prices, :priceable, polymorphic: true
    end
  end
end
