class CreateSpreeCmCommissionerTaxonStarRating < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_taxon_star_ratings , if_not_exists: true do |t|
      t.integer :star, null: false
      t.integer :kind, default: 0
      t.references :taxon, foreign_key: { to_table: :spree_taxons }
      t.references :product, foreign_key: { to_table: :spree_products }
      t.timestamps
    end
  end
end

