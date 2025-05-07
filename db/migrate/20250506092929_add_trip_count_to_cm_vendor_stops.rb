class AddTripCountToCmVendorStops < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_vendor_stops, :trip_count, :integer, default: 0, if_not_exists: true
  end
end
