class AddOriginDestinationIndexToProduct < ActiveRecord::Migration[7.0]
  def change
    add_index :spree_products, [:origin_id, :destination_id], name: 'index_spree_products_on_origin_id_and_destination_id'
  end
end
