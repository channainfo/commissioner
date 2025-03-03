class ChangeNotificationTypeToInteger < ActiveRecord::Migration[7.0]
  def change
    change_column :cm_customer_notifications, :notification_type, :integer, using: 'notification_type::integer', default: 0
  end
end
