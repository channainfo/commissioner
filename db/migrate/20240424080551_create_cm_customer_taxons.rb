class CreateCmCustomerTaxons < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_customer_taxons do |t|
      t.references :customer, null: false, foreign_key: { to_table: :cm_customers }
      t.references :taxon, null: false, foreign_key: { to_table: :spree_taxons }

      t.index [:customer_id, :taxon_id], unique: true

      t.timestamps
    end
  end
end
