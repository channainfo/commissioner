class AddIndexesToCmGuests < ActiveRecord::Migration[7.0]
  def change
    unless index_exists?(:cm_guests, :first_name)
      add_index :cm_guests, :first_name
    end

    unless index_exists?(:cm_guests, :last_name)
      add_index :cm_guests, :last_name
    end

    unless index_exists?(:cm_guests, :phone_number)
      add_index :cm_guests, :phone_number
    end
  end
end
