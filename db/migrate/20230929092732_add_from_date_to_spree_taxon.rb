class AddFromDateToSpreeTaxon < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_taxons, :from_date, :datetime, if_not_exists: true
    add_index :spree_taxons, :from_date, if_not_exists: true
  end
end
