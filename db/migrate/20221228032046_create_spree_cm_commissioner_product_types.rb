class CreateSpreeCmCommissionerProductTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :cm_product_types, if_not_exists: true do |t|
      t.string :name
      t.string :presentation
      t.boolean :enabled, :default => true

      t.timestamps
    end

    safety_remove_reference(:spree_vendors, :primary_product_type)
    safety_remove_reference(:spree_products, :product_type)
    safety_remove_reference(:spree_prototypes, :product_type)

    add_reference :spree_vendors, :primary_product_type, index: true, foreign_key: { to_table: :cm_product_types }
    add_reference :spree_products, :product_type, index: true, foreign_key: { to_table: :cm_product_types }
    add_reference :spree_prototypes, :product_type, foreign_key: { to_table: :cm_product_types }
  end

  def safety_remove_reference(table_name, reference)
    remove_reference table_name, reference if column_exists?(table_name, reference)
  end
end
