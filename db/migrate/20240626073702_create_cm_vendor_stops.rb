class CreateCmVendorStops < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_vendor_stops do |t|
      t.integer :vendor_id
      t.integer :stop_id
      t.integer :stop_type
      t.timestamps
    end
  end
end
