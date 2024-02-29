class AddOtherOccupationToGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_guests, :other_occupation, :string
  end
end
