class AddNameToSpreeWebhooksSubscriber < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_webhooks_subscribers, :name, :string, if_not_exists: true
  end
end
