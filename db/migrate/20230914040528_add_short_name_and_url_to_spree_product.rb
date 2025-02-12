class AddShortNameAndUrlToSpreeProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products, :short_name, :string, if_not_exists: true
    add_column :spree_products, :url, :string, if_not_exists: true
  end
end
