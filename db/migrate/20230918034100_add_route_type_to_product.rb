class AddRouteTypeToProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products, :route_type, :integer, if_not_exists: true
  end
end
