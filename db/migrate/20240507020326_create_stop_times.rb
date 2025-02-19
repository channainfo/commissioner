class CreateStopTimes < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_stop_times do |t|
      t.integer :trip_id
      t.integer :vehicle_id
      t.integer :from_stop_id
      t.integer :to_stop_id
      t.integer :sequence
      t.time :time
      t.timestamps
    end
  end
end
