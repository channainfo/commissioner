class AddOptFieldsToSpreeUser < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_users, :otp_enabled, :boolean, default: false
    add_column :spree_users, :otp_email, :boolean, default: nil
    add_column :spree_users, :otp_phone_number, :boolean, default: nil
  end
end
