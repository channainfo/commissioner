class CreateCmTripPoints < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_trip_points do |t|
      t.integer :trip_id
      t.integer :point_id
      t.integer :point_type
      t.timestamps
    end
  end
end
