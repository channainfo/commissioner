class AddAgeAndEmergencyContactToGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_guests, :age, :integer, if_not_exists: true
    add_column :cm_guests, :emergency_contact, :string, if_not_exists: true
  end
end
