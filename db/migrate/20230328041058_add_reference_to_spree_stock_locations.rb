class AddReferenceToSpreeStockLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_stock_locations, :reference, :string, if_not_exists: true
  end
end
