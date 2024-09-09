class AddDeviceTypeToSpreeCmDeviceToken < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_device_tokens, :device_type, :string, if_not_exists: true
  end
end
