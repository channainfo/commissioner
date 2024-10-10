class ChangeAmountPrecisionInStoreCreditEvents < ActiveRecord::Migration[7.0]
  def change
    change_column :spree_store_credit_events, :amount, :decimal, precision: 14, scale: 2
    change_column :spree_store_credit_events, :user_total_amount, :decimal, precision: 14, scale: 2
  end
end
