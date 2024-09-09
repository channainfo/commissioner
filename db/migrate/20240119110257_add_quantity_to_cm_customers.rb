class AddQuantityToCmCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_customers, :quantity, :integer, default: 1, if_not_exists: true
  end
end
