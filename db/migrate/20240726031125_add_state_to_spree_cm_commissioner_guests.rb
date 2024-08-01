class AddStateToSpreeCmCommissionerGuests < ActiveRecord::Migration[7.0]
  def change
    add_reference :cm_guests, :state, foreign_key: { to_table: :spree_states }, index: true, if_not_exists: true
  end
end
