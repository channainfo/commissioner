class CreateSpreeCmCommissionerPricingRates < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_pricing_rates, if_not_exists: true do |t|
      t.string :name
      t.integer :priority
      t.integer :match_policy, default: 0

      t.references :pricing_rateable, polymorphic: true, index: true, null: false
      t.datetime :effective_from, index: true
      t.datetime :effective_to, index: true

      t.text :preferences

      t.index [:effective_from, :effective_to]

      t.timestamps
    end
  end
end
