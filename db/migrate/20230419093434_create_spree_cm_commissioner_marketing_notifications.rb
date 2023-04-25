class CreateSpreeCmCommissionerMarketingNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_marketing_notifications do |t|
      t.string :title
      t.text :body
      t.text :exerpt
      t.string :url
      t.string :payload
      t.boolean :send_now, default: false
      t.text :user_ids, array: true, default: []
      t.timestamps
    end
  end
end
