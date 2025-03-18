class AddTenantIdToCmCustomerNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_customer_notifications, :tenant_id, :integer, if_not_exists: true
    add_index :cm_customer_notifications, :tenant_id, if_not_exists: true
  end
end
