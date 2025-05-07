class AddIndexToSpreeProducts < ActiveRecord::Migration[7.0]
  def change
    add_index :spree_products, :product_type unless index_exists?(:spree_products, :product_type)
  end
end
