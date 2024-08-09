class CreateSpreeCmCommissionerGuestCardClasses < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_guest_card_classes, if_not_exists: true do |t|
      t.string :type
      t.text :preferences
      t.references :taxon, foreign_key: { to_table: :spree_taxons }, index: true

      t.timestamps
    end
  end
end
