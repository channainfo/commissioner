class AddVendorIdToSpreeRoles < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_roles, :vendor_id, :integer, if_not_exists: true
    add_index :spree_roles, :vendor_id
  end
end
