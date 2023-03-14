class CreateSpreeCmCommissionerListingPrices < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_listing_prices, if_not_exists: true do |t|
      t.references :price_source, polymorphic: true, null: false

      t.date :date, null: false
      t.string :currency

      t.decimal :price, precision: 10, scale: 2, default: 0.0, null: false
      t.decimal :adjustment_total, precision: 10, scale: 2, default: 0.0
      t.decimal :additional_tax_total, precision: 10, scale: 2, default: 0.0
      t.decimal :promo_total, precision: 10, scale: 2, default: 0.0
      t.decimal :included_tax_total, precision: 10, scale: 2, default: 0.0, null: false
      t.decimal :pre_tax_amount, precision: 12, scale: 4, default: 0.0, null: false
      t.decimal :taxable_adjustment_total, precision: 10, scale: 2, default: 0.0, null: false
      t.decimal :non_taxable_adjustment_total, precision: 10, scale: 2, default: 0.0, null: false

      t.timestamps
    end

    add_index :cm_listing_prices, [
      :price_source_type,
      :price_source_id,
      :date,
      :currency
    ], unique: true, name: 'index_cm_listing_prices_uniqueness', if_not_exists: true
  end
end
