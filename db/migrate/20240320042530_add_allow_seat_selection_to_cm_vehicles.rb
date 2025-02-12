class AddAllowSeatSelectionToCmVehicles < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_vehicles, :allow_seat_selection, :boolean, default: true
  end
end
