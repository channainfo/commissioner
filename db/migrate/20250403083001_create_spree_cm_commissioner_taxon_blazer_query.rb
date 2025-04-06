class CreateSpreeCmCommissionerTaxonBlazerQuery < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_taxon_blazer_queries, if_not_exists: true  do |t|
      t.references :taxon, foreign_key: { to_table: :spree_taxons }, null: false, index: true
      t.references :blazer_query,  foreign_key: { to_table: :blazer_queries }, null: false, index: true
      t.timestamps
    end
  end
end

