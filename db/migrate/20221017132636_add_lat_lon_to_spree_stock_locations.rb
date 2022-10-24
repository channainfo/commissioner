class AddLatLonToSpreeStockLocations < ActiveRecord::Migration[6.1]
  def change
    # 90 to -90:
    # 00.00000000
    add_column :spree_stock_locations, :lat, :decimal, precision: 10, scale: 8

    # 180 to -180:
    # 000.00000000
    add_column :spree_stock_locations, :lon, :decimal, precision: 11, scale: 8
  end
end
