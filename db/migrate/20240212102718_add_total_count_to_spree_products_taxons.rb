class AddTotalCountToSpreeProductsTaxons < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products_taxons, :total_count, :integer, default: 0, if_not_exists: true
  end
end
