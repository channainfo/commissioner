class AddSubTitleToSpreeTaxon < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_taxons, :subtitle, :string, if_not_exists: true
  end
end
