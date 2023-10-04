class AddToDateToSpreeTaxon < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_taxons, :to_date, :datetime, if_not_exists: true
    add_index :spree_taxons, :to_date, if_not_exists: true
  end
end
