class AddNumberCmCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_customers, :number, :string, if_not_exists: true
  end
end
