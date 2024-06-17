class AddActionLabelToCmCustomerNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_customer_notifications, :action_label, :string, if_not_exists: true
  end
end
