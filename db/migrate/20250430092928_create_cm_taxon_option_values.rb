class CreateCmTaxonOptionValues < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_taxon_option_values do |t|
      t.references :taxon, null: false, if_not_exists: true
      t.references :option_value, null: false, if_not_exists: true
      t.timestamps
    end
  end
end
