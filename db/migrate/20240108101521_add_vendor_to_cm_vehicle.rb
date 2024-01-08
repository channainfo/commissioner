class AddVendorToCmVehicle < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_vehicles, :vendor_id, :integer
  end
end
