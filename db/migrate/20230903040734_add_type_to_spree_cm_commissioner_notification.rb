class AddTypeToSpreeCmCommissionerNotification < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_notifications, :type, :string, if_not_exists: true
  end
end
