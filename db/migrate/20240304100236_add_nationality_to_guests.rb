class AddNationalityToGuests < ActiveRecord::Migration[7.0]
  def change
    add_reference :cm_guests, :nationality, foreign_key: { to_table: :spree_taxons }, index: true, if_not_exists: true
  end
end
