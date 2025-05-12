class AddTenantIdToSpreeCmsPages < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_cms_pages, :tenant_id, :integer, if_not_exists: true
    add_index :spree_cms_pages, :tenant_id, if_not_exists: true
  end
end
