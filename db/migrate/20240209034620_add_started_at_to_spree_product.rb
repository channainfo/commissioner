class AddStartedAtToSpreeProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products, :started_at, :datetime, if_not_exists: true
    add_index :spree_products, :started_at, if_not_exists: true
  end
end
