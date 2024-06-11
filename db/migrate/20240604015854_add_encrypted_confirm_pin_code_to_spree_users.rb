class AddEncryptedConfirmPinCodeToSpreeUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_users, :encrypted_confirm_pin_code, :string
  end
end
