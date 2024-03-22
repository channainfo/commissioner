class CreateSpreeCmCommissionerPricingActions < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_pricing_actions, if_not_exists: true do |t|
      t.string :type, index: true
      t.integer :priority
      t.text :preferences

      t.references :pricing_model, index: true, foreign_key: { to_table: :cm_pricing_models }

      t.timestamps
    end
  end
end
