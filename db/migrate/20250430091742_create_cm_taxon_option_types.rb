class CreateCmTaxonOptionTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_taxon_option_types do |t|
      t.references :taxon, null: false, if_not_exists: true
      t.references :option_type, null: false, if_not_exists: true
      t.timestamps
    end
  end
end
