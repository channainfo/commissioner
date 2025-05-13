class CreateSpreeCmCommissionerTransactionalEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_transactional_emails, if_not_exists: true do |t|
      t.references :taxon, null: true, foreign_key: { to_table: :spree_taxons }
      t.references :recipient, polymorphic: true, null: false
      t.datetime :sent_at

      t.timestamps
    end
    add_index :cm_transactional_emails, [:taxon_id, :recipient_type, :recipient_id], unique: true, if_not_exists: true, name: 'idx_transactional_email_taxon_recipient'
  end
end
