class CreateSpreeCmCommissionerOptionValueVendors < ActiveRecord::Migration[6.1]
  def change
    create_table :cm_option_value_vendors do |t|
      t.references :vendor
      t.references :option_value

      t.timestamps
    end
  end
end
