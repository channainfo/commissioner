class RemoveTenantIdFromCmNotifications < ActiveRecord::Migration[7.0]
  def change
    remove_index :cm_notifications, :tenant_id, if_exists: true
    remove_column :cm_notifications, :tenant_id, if_exists: true
  end
end
