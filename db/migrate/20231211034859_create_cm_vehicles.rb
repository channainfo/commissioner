class CreateCmVehicles < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_vehicles, if_not_exists: true do |t|
      t.string :code
      t.string :license_plate
      t.references :vehicle_type, foreign_key: { to_table: :cm_vehicle_types }

      t.timestamps
    end
  end
end
