class CreateSpreeCmCommissionerOptionValueVehicleType < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_option_value_vehicle_types do |t|
      t.references :vehicle_type
      t.references :option_value
      t.timestamps
    end
  end
end
