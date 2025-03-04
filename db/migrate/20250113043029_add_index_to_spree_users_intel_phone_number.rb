class AddIndexToSpreeUsersIntelPhoneNumber < ActiveRecord::Migration[7.0]
  def change
    add_index :spree_users, :intel_phone_number, if_not_exists: true
  end
end
