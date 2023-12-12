class CreateSpreeCmCommissionerVehicleSeat < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_vehicle_seats do |t|
      t.string :label
      t.integer :seat_type
      t.integer :row
      t.integer :column
      t.string  :code
      t.integer :vehicle_type_id
      t.timestamps
    end
  end
end
