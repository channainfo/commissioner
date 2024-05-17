class CreateSpreeCmCommissionerTaxonReview < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_taxon_review, if_not_exists: true do |t|
      t.integer :rating, null: false
      t.references :review, foreign_key: { to_table: :spree_reviews }
      t.references :taxon_star_rating, foreign_key: { to_table: :cm_taxon_star_ratings }

      t.timestamps
    end
  end
end
