class AddBackgroundColorAndForegroundColorToTaxon < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_taxons, :preferences, :text, if_not_exists: true
  end
end
