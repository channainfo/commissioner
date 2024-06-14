class AddSecureTokenFieldToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_users, :secure_token, :string, if_not_exists: true
  end
end
