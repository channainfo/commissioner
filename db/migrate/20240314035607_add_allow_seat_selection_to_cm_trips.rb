class AddAllowSeatSelectionToCmTrips < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_trips, :allow_seat_selection, :boolean, default: true, if_not_exists: true
  end
end
