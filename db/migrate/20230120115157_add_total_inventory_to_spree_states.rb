class AddTotalInventoryToSpreeStates < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_states, :total_inventory, :integer
  end
end
