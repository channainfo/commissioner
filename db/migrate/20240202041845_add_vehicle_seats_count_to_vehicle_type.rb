class AddVehicleSeatsCountToVehicleType < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_vehicle_types, :vehicle_seats_count, :integer, default: 0
  end
end
