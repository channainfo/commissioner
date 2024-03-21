class CreateSpreeCmCommissionerAppliedPricingModels < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_applied_pricing_models, if_not_exists: true do |t|
      t.references :line_item
      t.references :pricing_model

      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :quantity, null: false
      t.datetime :date
      t.text :preferences

      t.timestamps
    end
  end
end
