class AddVehicleTypeIdIndexToCmVehicleSeats < ActiveRecord::Migration[7.0]
  def change
    add_index :cm_vehicle_seats, :vehicle_type_id, name: 'index_cm_vehicle_seats_on_vehicle_type_id'
  end
end
