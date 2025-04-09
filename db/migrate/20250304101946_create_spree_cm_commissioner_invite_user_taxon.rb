class CreateSpreeCmCommissionerInviteUserTaxon < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_invite_user_taxons, if_not_exists: true do |t|
      t.references :invite, foreign_key: { to_table: :cm_invites }, null: true, index: true
      t.references :user_taxon,  foreign_key: { to_table: :cm_user_taxons }, null: true, index: true
      t.string :email, index: true
      t.datetime :confirmed_at
      t.timestamps
    end
  end
end
