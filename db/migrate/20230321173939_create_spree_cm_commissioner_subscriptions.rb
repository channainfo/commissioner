class CreateSpreeCmCommissionerSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_subscriptions do |t|
      t.date :start_date, null: false
      t.integer :status, default: 0, null: false

      t.references :variant, foreign_key: { to_table: :spree_variants }, null: false
      t.references :customer, foreign_key: { to_table: :cm_customers }, null: false

      t.timestamps
    end
  end
end
