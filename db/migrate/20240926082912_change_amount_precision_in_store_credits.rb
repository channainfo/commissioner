class ChangeAmountPrecisionInStoreCredits < ActiveRecord::Migration[7.0]
  def change
    change_column :spree_store_credits, :amount, :decimal, precision: 14, scale: 2
    change_column :spree_store_credits, :amount_used, :decimal, precision: 14, scale: 2
    change_column :spree_store_credits, :amount_authorized, :decimal, precision: 14, scale: 2
  end
end
