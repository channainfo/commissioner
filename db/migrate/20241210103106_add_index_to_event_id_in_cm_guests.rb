class AddIndexToEventIdInCmGuests < ActiveRecord::Migration[7.0]
  def change
    add_index :cm_guests, :event_id, if_not_exists: true
  end
end
