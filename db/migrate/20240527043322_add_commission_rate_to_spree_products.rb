class AddCommissionRateToSpreeProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products, :commission_rate, :float, null: true, if_not_exists: true
  end
end
