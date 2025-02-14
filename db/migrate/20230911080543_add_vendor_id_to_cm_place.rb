class AddVendorIdToCmPlace < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_places, :vendor_id, :int, optional: true, if_not_exists: true
  end
end
