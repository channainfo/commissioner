class AddStatusToCmVehicleType < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_vehicle_types, :status, :string
  end
end
