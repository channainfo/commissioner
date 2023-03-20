class AddTaxonReferenceToUsers < ActiveRecord::Migration[7.0]
  def change
    add_reference :spree_users, :taxon, index: true, if_not_exists: true
    add_foreign_key :spree_users, :spree_taxons, column: :taxon_id, if_not_exists: true
  end
end
