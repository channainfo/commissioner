class AddVehicleIdToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products, :vehicle_id, :integer, index: true
  end
end
