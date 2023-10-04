class AddColumnFullAddressToSpreeVendor < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_vendors, :full_address, :text, if_not_exists: true
  end
end
