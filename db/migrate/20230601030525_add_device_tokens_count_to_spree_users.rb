class AddDeviceTokensCountToSpreeUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_users, :device_tokens_count, :integer, default: 0, if_not_exists: true
  end
end
