class RenameEncryptedConfirmPinCodeToConfirmPinCodeDigestToSpreeUsers < ActiveRecord::Migration[7.0]
  def change
    rename_column :spree_users, :encrypted_confirm_pin_code, :confirm_pin_code_digest
    change_column :spree_users, :confirm_pin_code_digest, :string, limit: 128
  end
end
