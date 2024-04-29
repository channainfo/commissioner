class CreateSpreeCmCommissionerAppliedPricingRates < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_applied_pricing_rates, if_not_exists: true do |t|
      t.references :line_item, foreign_key: { to_table: :spree_line_items }
      t.references :pricing_rate, foreign_key: { to_table: :cm_pricing_rates }

      t.decimal :amount, precision: 10, scale: 2, null: false
      t.jsonb :options

      t.timestamps
    end
  end
end
