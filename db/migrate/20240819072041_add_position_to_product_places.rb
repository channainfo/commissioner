class AddPositionToProductPlaces < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_product_places, :position, :integer, default: 0, if_not_exists: true
  end
end
