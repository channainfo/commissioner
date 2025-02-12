class AddOriginDestinationIndexToCmTrips < ActiveRecord::Migration[7.0]
  def change
    add_index :cm_trips, [:origin_id, :destination_id], name: 'index_cm_trips_on_origin_id_and_destination_id'
    add_index :cm_trips, :product_id, name: 'index_cm_trips_on_product_id'
  end
end
