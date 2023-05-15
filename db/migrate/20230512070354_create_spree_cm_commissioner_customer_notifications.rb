class CreateSpreeCmCommissionerCustomerNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_customer_notifications, if_not_exists: true do |t|
      t.string :title
      t.text :body
      t.string :url
      t.string :notification_type
      t.string :payload
      t.string :excerpt
      t.datetime :started_at
      t.datetime :sent_at

      t.text :user_ids, array: true, default: []

      t.timestamps
    end
  end
end
