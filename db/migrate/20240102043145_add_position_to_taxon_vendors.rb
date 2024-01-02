class AddPositionToTaxonVendors < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_taxon_vendors, :position, :integer, default: 0, if_not_exists: true
  end
end
