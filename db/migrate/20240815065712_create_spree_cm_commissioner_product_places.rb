class CreateSpreeCmCommissionerProductPlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_product_places, if_not_exists: true do |t|
      t.references :place, null: false, foreign_key: { to_table: :cm_places }
      t.references :product, null: false, foreign_key: { to_table: :spree_products }
      t.integer :checkinable_distance, default: 100
      t.integer :type, default: 0, null: false

      t.index [:place_id, :product_id], unique: true

      t.timestamps
    end
  end
end

