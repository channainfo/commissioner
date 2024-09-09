class AddIndexToTokenInCmGuests < ActiveRecord::Migration[7.0]
  def change
    add_index :cm_guests, :token, if_not_exists: true
  end
end
