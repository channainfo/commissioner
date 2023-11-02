class CreateSpreeCmCommissionerWebhooksSubscriberRules < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_webhooks_subscriber_rules, if_not_exists: true do |t|
      t.references :subscriber
      t.text :preferences
      t.string :type

      t.timestamps
    end
  end
end
