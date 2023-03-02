class AddPhoneNumberToSpreeOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_orders, :phone_number, :string, limit: 50, if_not_exists: true
    add_column :spree_orders, :intel_phone_number, :string, limit: 50, index: true, if_not_exists: true
    add_column :spree_orders, :country_code, :string, limit: 5, if_not_exists: true
  end
end
