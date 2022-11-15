class AddMinMaxPriceToSpreeVendors < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_vendors, :min_price, :decimal, precision: 10, scale: 2, default: "0.0"
    add_column :spree_vendors, :max_price, :decimal, precision: 10, scale: 2, default: "0.0"
  end
end
