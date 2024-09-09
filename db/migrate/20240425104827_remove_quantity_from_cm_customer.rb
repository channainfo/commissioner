class RemoveQuantityFromCmCustomer < ActiveRecord::Migration[7.0]
  def change
    remove_column :cm_customers, :quantity, :integer, if_exists: true
  end
end
