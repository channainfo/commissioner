class AddActiveToCmCustomerNotifications < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:cm_customer_notifications, :active)
      add_column :cm_customer_notifications, :active, :boolean, default: true
    end
  end
end
