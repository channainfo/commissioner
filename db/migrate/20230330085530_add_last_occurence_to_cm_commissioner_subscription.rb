class AddLastOccurenceToCmCommissionerSubscription < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_subscriptions, :last_occurence , :date, if_not_exists: true
  end
end
