class CreateCmTripStops < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_trip_stops do |t|
      t.integer :trip_id
      t.integer :stop_id
      t.integer :stop_type
      t.timestamps
    end
  end
end
