class CreateSpreeCmCommissionerDeviceTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_device_tokens do |t|
      t.integer :user_id
      t.string :registration_token
      t.string :client_name
      t.string :client_version
      t.text :meta

      t.timestamps
    end

    add_index :cm_device_tokens, :user_id
  end
end
