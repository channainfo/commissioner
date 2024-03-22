class CreateSpreeCmCommissionerPricingRules < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_pricing_rules, if_not_exists: true do |t|
      t.string :type, index: true
      t.integer :priority
      t.text :preferences

      t.references :ruleable, polymorphic: true, index: true, null: false

      t.timestamps
    end
  end
end
