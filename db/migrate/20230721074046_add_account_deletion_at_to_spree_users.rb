class AddAccountDeletionAtToSpreeUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_users, :account_deletion_at, :datetime, if_not_exists: true
  end
end
