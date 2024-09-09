class CreateSpreeCmCommissionerCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_customers do |t|
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.date :dob

      t.string :email
      t.string :phone_number, limit: 50
      t.string :intel_phone_number, limit: 50, index: true
      t.string :country_code, limit: 5

      t.references :vendor, foreign_key: { to_table: :spree_vendors }, null: false
      t.references :taxon, foreign_key: { to_table: :spree_taxons }
      t.references :user, foreign_key: { to_table: :spree_users }

      t.timestamps
    end
  end
end
