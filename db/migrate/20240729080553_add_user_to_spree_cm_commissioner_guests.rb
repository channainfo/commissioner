class AddUserToSpreeCmCommissionerGuests < ActiveRecord::Migration[7.0]
  def change
    add_reference :cm_guests, :user, foreign_key: { to_table: :spree_users }, index: true, if_not_exists: true
  end
end


