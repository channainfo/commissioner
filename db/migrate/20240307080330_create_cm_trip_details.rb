class CreateCmTripDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_trip_details, if_not_exists: true do |t|
      t.integer :product_id
      t.integer :vehicle_id
      t.integer :origin_id
      t.integer :destination_id
      t.time :departure_time
      t.integer :duration
      t.timestamps
    end
  end
end
