class RemoveTypeFromSpreeCmCommissionerNotifications < ActiveRecord::Migration[7.0]
  def change
    remove_column :cm_notifications, :type, :string, if_exists: true
  end
end
