class AddOptFieldsToSpreeUser < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_users, :otp_enabled, :boolean, default: false
    add_column :spree_users, :otp_email, :boolean, default: false
    add_column :spree_users, :otp_phone_number, :boolean, default: false
  end
end
