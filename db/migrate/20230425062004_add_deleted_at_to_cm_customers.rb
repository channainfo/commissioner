class AddDeletedAtToCmCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_customers, :deleted_at, :timestamp, if_not_exists: true
  end
end
