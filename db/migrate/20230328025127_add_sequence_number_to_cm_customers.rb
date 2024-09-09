class AddSequenceNumberToCmCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_customers, :sequence_number, :string, if_not_exists: true
    add_index :cm_customers, :sequence_number
  end
end
