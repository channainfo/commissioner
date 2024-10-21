class CreateSpreeCmCommissionerTemplateGuests < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_template_guests, if_not_exists: true do |t|
      t.string :first_name
      t.string :last_name
      t.date :dob
      t.integer :gender, default: 0
      t.string :phone_number, limit: 50
      t.string :emergency_contact, limit: 50
      t.boolean :is_default, default: false
      t.references :user, foreign_key: { to_table: :spree_users }
      t.references :nationality, foreign_key: { to_table: :spree_taxons }
      t.references :occupation, foreign_key: { to_table: :spree_taxons }
      t.string :other_occupation
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
