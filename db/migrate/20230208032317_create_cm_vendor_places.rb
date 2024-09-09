class CreateCmVendorPlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_vendor_places, if_not_exists: true do |t|
      t.references :vendor
      t.references :place
      t.float :distance
      t.integer :position
      t.index [:vendor_id, :place_id], name: 'vendor_place'

      t.timestamps
    end
  end
end
