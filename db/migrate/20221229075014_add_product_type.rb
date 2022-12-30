class AddProductType < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_vendors, :primary_product_type, :integer
    add_column :spree_products, :product_type, :integer
    add_column :spree_prototypes, :product_type, :integer
  end
end
