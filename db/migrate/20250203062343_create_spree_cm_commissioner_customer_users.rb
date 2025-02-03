class CreateSpreeCmCommissionerCustomerUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_customer_users do |t|
      t.references :customer, null: false, foreign_key: { to_table: :cm_customers }
      t.references :user, null: false, foreign_key: { to_table: :spree_users }

      t.index [:customer_id, :user_id], unique: true

      t.timestamps
    end
  end
end
