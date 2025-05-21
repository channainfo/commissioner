class CreateCmInventoryItems < ActiveRecord::Migration[7.0]
  def up
    create_table :cm_inventory_items, if_not_exists: true do |t|
      t.integer :variant_id
      t.date :inventory_date
      t.integer :max_capacity, default: 0, null: false
      t.integer :quantity_available, default: 0, null: false
      t.integer :product_type, default: 0, null: false

      t.timestamps
    end

    add_index :cm_inventory_items, :variant_id, if_not_exists: true
    add_index :cm_inventory_items, :inventory_date, if_not_exists: true
    add_index :cm_inventory_items, [:variant_id, :inventory_date], unique: true, if_not_exists: true
  end

  def down
    drop_table :cm_inventory_items
  end
end
