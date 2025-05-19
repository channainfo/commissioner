class AddMaxOrderQuantityToSpreeProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products, :max_order_quantity, :integer, if_not_exists: true
  end
end
