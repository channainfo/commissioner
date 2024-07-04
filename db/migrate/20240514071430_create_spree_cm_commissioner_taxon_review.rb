class CreateSpreeCmCommissionerTaxonReview < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_taxon_reviews, if_not_exists: true do |t|
      t.integer :rating
      t.references :review, foreign_key: { to_table: :spree_reviews }
      t.references :taxon, foreign_key: { to_table: :spree_taxons }

      t.timestamps
    end
  end
end
