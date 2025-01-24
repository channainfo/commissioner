class AddCartItemCountAndUnreadNotificationCountToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_users, :cart_item_count, :integer, default: 0, if_not_exists: true
    add_column :spree_users, :unread_notification_count, :integer, default: 0, if_not_exists: true
  end
end
