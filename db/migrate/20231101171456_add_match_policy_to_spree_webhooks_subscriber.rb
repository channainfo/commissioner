class AddMatchPolicyToSpreeWebhooksSubscriber < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_webhooks_subscribers, :match_policy, :integer, default: 0, null: false, if_not_exists: true
  end
end
