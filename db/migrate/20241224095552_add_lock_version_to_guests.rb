class AddLockVersionToGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_guests, :lock_version, :integer, default: 0, null: false
  end
end
