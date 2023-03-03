class CreateCmVendorPricingRules < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_vendor_pricing_rules, if_not_exists: true do |t|
      t.json :date_rule
      t.string :operator
      t.decimal :amount, precision: 10, scale: 2, default: "0.0"
      t.integer :length, default: 1
      t.integer :position
      t.boolean :active, default: true
      t.boolean :free_cancellation, default: false
      t.references :vendor

      t.timestamps
    end
  end
end
