class AddPricingsColumnsToLineItems < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_line_items, :pricing_rates_amount, :decimal, precision: 10, scale: 2, if_not_exists: true
    add_column :spree_line_items, :pricing_models_amount, :decimal, precision: 10, scale: 2, if_not_exists: true
    add_column :spree_line_items, :pricing_subtotal, :decimal, precision: 10, scale: 2, if_not_exists: true
  end
end
