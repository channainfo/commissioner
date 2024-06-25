class AddConfirmPinCodeEnabledToSpreeUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_users, :confirm_pin_code_enabled, :boolean, default: false
  end
end
