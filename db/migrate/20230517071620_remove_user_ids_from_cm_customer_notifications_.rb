class RemoveUserIdsFromCmCustomerNotifications < ActiveRecord::Migration[7.0]
  def change
    remove_column :cm_customer_notifications, :user_ids, :text
  end
end
