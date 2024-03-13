class RemoveOriginDestintaionVehicleFromProduct < ActiveRecord::Migration[7.0]
  def change
    remove_column :spree_products, :origin_id, :integer
    remove_column :spree_products, :destination_id, :integer
    remove_column :spree_products, :vehicle_id, :integer
  end
end
