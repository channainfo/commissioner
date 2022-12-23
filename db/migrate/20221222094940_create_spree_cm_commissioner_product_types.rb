class CreateSpreeCmCommissionerProductTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :cm_product_types, if_not_exists: true do |t|
      t.string :name
      t.string :presentation
      t.boolean :enabled, :default => true

      t.timestamps
    end

    remove_reference :spree_products, :product_type, if_exists: true
    remove_reference :spree_prototypes, :product_type, if_exists: true

    add_reference :spree_products, :product_type, index: true, foreign_key: { to_table: :cm_product_types }
    add_reference :spree_prototypes, :product_type, foreign_key: { to_table: :cm_product_types }
  end
end
