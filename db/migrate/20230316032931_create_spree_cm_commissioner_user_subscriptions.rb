class CreateSpreeCmCommissionerUserSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_user_subscriptions do |t|
      t.integer :user_id
      t.integer :variant_id
      t.date :start_date
      t.date :end_date
      t.integer :status, default: 0

      t.timestamps
    end
    add_foreign_key :cm_user_subscriptions, :spree_users, column: :user_id, if_not_exists: true
    add_foreign_key :cm_user_subscriptions, :spree_variants, column: :variant_id, if_not_exists: true
  end
end
