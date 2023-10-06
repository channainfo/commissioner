class CreateSpreeCmCommissionerVehicleType < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_vehicle_types do |t|
      t.string :name
      t.integer :route_type
      t.integer :vendor_id
      t.timestamps
    end
  end
end
