class AddSendAllToSpreeCmCustomerNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_customer_notifications, :send_all, :boolean, default: false, if_not_exists: true
  end
end
