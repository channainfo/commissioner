class ChangeColumnOrderNullToSpreeAdjustments < ActiveRecord::Migration[7.0]
  def change
    change_column_null :spree_adjustments, :order_id, true
  end
end
