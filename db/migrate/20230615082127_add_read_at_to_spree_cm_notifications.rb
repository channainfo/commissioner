class AddReadAtToSpreeCmNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_notifications, :read_at, :datetime, if_not_exists: true
    add_index :cm_notifications, :read_at, if_not_exists: true
  end
end
