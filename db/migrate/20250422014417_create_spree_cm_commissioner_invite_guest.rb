class CreateSpreeCmCommissionerInviteGuest < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_invite_guests, if_not_exists: true do |t|
      t.references :variant, foreign_key: { to_table: :spree_variants }, null: true, index: true
      t.references :order, foreign_key: { to_table: :spree_orders }, null: true, index: true
      t.references :taxon, foreign_key: { to_table: :spree_taxons }, null: true, index: true
      t.string :email, index: true
      t.integer :quantity, default: 1
      t.string :token, null: false, unique: true
      t.integer :invite_type, default: 0
      t.integer :claimed_status, default: 0
      t.string :issued_to
      t.datetime :expiration_date
      t.text :remark
      t.datetime :expires_at
      t.datetime :claimed_at
      t.datetime :email_send_at
      t.timestamps
    end
  end
end
