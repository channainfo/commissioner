class AddAvailableOnToSpreeTaxons < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_taxons, :available_on, :datetime, if_not_exists: true
  end
end
