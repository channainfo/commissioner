class CreateSpreeCmCommissionerUserTaxons < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_user_taxons, if_not_exists: true do |t|
      t.references :taxon, foreign_key: { to_table: :spree_taxons }
      t.references :user
      t.string :type

      t.index [:taxon_id, :user_id], unique: true

      t.timestamps
    end
  end
end
