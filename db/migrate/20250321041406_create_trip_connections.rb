class CreateTripConnections < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_trip_connections, if_not_exists: true do |t|
      t.references :from_trip, null: false, foreign_key: { to_table: :spree_variants }, index: true,if_not_exists: true
      t.references :to_trip, null: false, foreign_key: { to_table: :spree_variants }, index: true, if_not_exists: true
      t.integer :connection_time_minutes, null: false, if_not_exists: true
      t.text :description, null: true, if_not_exists: true

      t.timestamps
    end
  end
end
