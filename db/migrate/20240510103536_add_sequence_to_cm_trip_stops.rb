class AddSequenceToCmTripStops < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_trip_stops, :sequence, :integer, default: 0, if_not_exists: true
  end
end
