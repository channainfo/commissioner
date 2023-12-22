class AddLineItemReferenceToSpreeCmCommissionerGuests < ActiveRecord::Migration[7.0]
  def change
    add_reference :cm_guests, :line_item, foreign_key: { to_table: :spree_line_items }, index: true, if_not_exists: true
  end
end
