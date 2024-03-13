class AddOriginDestinationIndexToCmTripDetails < ActiveRecord::Migration[7.0]
  def change
    add_index :cm_trip_details, [:origin_id, :destination_id], name: 'index_cm_trip_details_on_origin_id_and_destination_id'
    add_index :cm_trip_details, :product_id, name: 'index_cm_trip_details_on_product_id'
  end
end
