class AddTotalInventoryAndStateIdToSpreeVendors < ActiveRecord::Migration[6.1]
  def change
    change_table :spree_vendors, bulk: true, if_not_exists: true do |t|
      t.integer :total_inventory
      t.integer :state_id
      t.index :state_id
    end
  end
end
