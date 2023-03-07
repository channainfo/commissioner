class AddMinMaxPriceToSpreeVendors < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_vendors, :min_price, :decimal, precision: 10, scale: 2, default: "0.0", if_not_exists: true
    add_column :spree_vendors, :max_price, :decimal, precision: 10, scale: 2, default: "0.0", if_not_exists: true
  end
end
