class AddPhoneNumberToSpreeUser < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_users, :phone_number, :string, limit: 50, if_not_exists: true
    add_column :spree_users, :intel_phone_number, :string, limit: 50, index: true, if_not_exists: true
    add_column :spree_users, :country_code, :string, limit: 5, if_not_exists: true
  end
end
