class AddAddressesToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_reference :cm_customers, :ship_address, index: true, foreign_key: { to_table: :spree_addresses }, if_not_exists: true
    add_reference :cm_customers, :bill_address, index: true, foreign_key: { to_table: :spree_addresses }, if_not_exists: true
  end
end
