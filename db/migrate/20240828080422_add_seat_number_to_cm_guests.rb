class AddSeatNumberToCmGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_guests, :seat_number, :string, if_not_exists: true
  end
end
