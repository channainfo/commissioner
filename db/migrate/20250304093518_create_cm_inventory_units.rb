class CreateCmInventoryUnits < ActiveRecord::Migration[7.0]
  def up
    create_table :cm_inventory_units, if_not_exists: true do |t|
      t.integer :variant_id
      t.date    :inventory_date
      t.integer :max_capacity, default: 0
      t.integer :quantity_available, default: 0
      t.string  :service_type #-- 'event', 'bus', 'accommodation'

      t.timestamps
    end

    add_index :cm_inventory_units, :variant_id
    add_index :cm_inventory_units, :inventory_date
    add_index :cm_inventory_units, :service_type
    add_index :cm_inventory_units, [:variant_id, :inventory_date], unique: true
  end

  def down
    drop_table :cm_inventory_units

    remove_index :cm_inventory_units, :variant_id
    remove_index :cm_inventory_units, :inventory_date
    remove_index :cm_inventory_units, :service_type
  end
end
