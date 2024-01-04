class ChangeTaxonReferenceToOccupationInSpreeCmCommissionerGuests < ActiveRecord::Migration[7.0]
  def change
    remove_reference :cm_guests, :taxon, foreign_key: { to_table: :spree_taxons }
    add_reference :cm_guests, :occupation, foreign_key: { to_table: :spree_taxons }, index: true, if_not_exists: true
  end
end
