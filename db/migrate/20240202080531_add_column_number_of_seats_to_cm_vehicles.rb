class AddColumnNumberOfSeatsToCmVehicles < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_vehicles, :number_of_seats, :integer, default: 0
  end
end
