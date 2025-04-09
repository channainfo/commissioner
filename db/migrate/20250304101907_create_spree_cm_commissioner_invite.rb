class CreateSpreeCmCommissionerInvite < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_invites, if_not_exists: true do |t|
      t.string :token, null: false, unique: true
      t.datetime :expires_at
      t.string :type
      t.references :inviter, null: false, foreign_key: { to_table: :spree_users }, index: true
      t.references :taxon, null: false, foreign_key: { to_table: :spree_taxons }, index: true
      t.timestamps
    end
  end
end
