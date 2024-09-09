class RemoveSendAllFromCmCustomerNotifications < ActiveRecord::Migration[7.0]
  def change
    remove_column :cm_customer_notifications, :send_all, :boolean, if_exists: true
  end
end
