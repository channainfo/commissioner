class AddQuantityToCmSubscription < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_subscriptions, :quantity, :integer, if_not_exists: true
  end
end
