class AddRouteTypeToCmVehicle < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_vehicles, :route_type, :integer
  end
end
