class RemoveTenantIdAndVendorIdFromCmCustomerNotifications < ActiveRecord::Migration[7.0]
  def change
    remove_column :cm_customer_notifications, :tenant_id, :integer if column_exists?(:cm_customer_notifications, :tenant_id)

    unless column_exists?(:cm_customer_notifications, :vendor_id)
      add_column :cm_customer_notifications, :vendor_id, :integer
    end
  end
end
