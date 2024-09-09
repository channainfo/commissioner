class AddSubscriptionIdToOrders < ActiveRecord::Migration[7.0]
    def change
      add_column :spree_orders, :subscription_id, :integer
      add_foreign_key :spree_orders, :cm_subscriptions, column: :subscription_id
    end
end
