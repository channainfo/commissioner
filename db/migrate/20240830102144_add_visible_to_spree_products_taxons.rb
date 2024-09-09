class AddVisibleToSpreeProductsTaxons < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products_taxons, :visible, :boolean, default: true
  end
end
