class AddAddressToSpreeCmCommissioner < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_guests, :address, :string, if_not_exists: true
  end
end
