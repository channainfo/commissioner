class CreateCmInventoryItems < ActiveRecord::Migration[7.0]
  def up
    create_table :cm_inventory_items, if_not_exists: true do |t|
      t.integer :variant_id
      t.date    :inventory_date
      t.integer :max_capacity, default: 0
      t.integer :quantity_available, default: 0
      t.string  :product_type #-- 'event', 'bus', 'accommodation'

      t.timestamps
    end

    add_index :cm_inventory_items, :variant_id
    add_index :cm_inventory_items, :inventory_date
    add_index :cm_inventory_items, [:variant_id, :inventory_date], unique: true
  end

  def down
    drop_table :cm_inventory_items
  end
end
