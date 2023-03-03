class CreateSpreeCmCommissionerVendorOptionTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :cm_vendor_option_types, if_not_exists: true do |t|
      t.references :vendor
      t.references :option_type

      t.timestamps
    end
  end
end
