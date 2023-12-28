class CreateSpreeCmCommissionerTaxonVendors < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_taxon_vendors do |t|
      t.references :taxon
      t.references :vendor

      t.index [:taxon_id, :vendor_id], unique: true

      t.timestamps
    end
  end
end
