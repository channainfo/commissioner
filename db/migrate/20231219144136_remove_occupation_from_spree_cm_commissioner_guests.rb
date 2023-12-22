class RemoveOccupationFromSpreeCmCommissionerGuests < ActiveRecord::Migration[7.0]
  def change
    remove_column :cm_guests, :occupation, :integer, if_exists: true
  end
end
