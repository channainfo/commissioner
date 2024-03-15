class ChangePriceableToRequiredInSpreePrices < ActiveRecord::Migration[7.0]
  def change
    change_column :spree_prices, :priceable_id, :integer, null: false
    change_column :spree_prices, :priceable_type, :string, null: false
  end
end
