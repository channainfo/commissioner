class AddOriginDestinationToProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products, :origin_id, :integer
    add_column :spree_products, :destination_id, :integer
  end
end
