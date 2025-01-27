class AddTenantIdToSpreeVendors < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_vendors, :tenant_id, :integer, if_not_exists: true
    add_index :spree_vendors, :tenant_id, if_not_exists: true
  end
end
