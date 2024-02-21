class AddEntryTypeToGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_guests, :entry_type, :integer, default: 0
  end
end
