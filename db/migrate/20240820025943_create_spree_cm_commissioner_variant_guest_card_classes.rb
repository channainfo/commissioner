class CreateSpreeCmCommissionerVariantGuestCardClasses < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_variant_guest_card_classes do |t|
      t.references :variant, null: false, foreign_key: { to_table: :spree_variants }
      t.references :guest_card_class, null: false, foreign_key: { to_table: :cm_guest_card_classes }

      t.timestamps
    end

    add_index :cm_variant_guest_card_classes, [:variant_id, :guest_card_class_id], unique: true, name: 'index_variant_guest_cards_on_variant_and_guest_card'
  end
end
