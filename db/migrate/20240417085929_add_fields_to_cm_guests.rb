class AddFieldsToCmGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_guests, :token, :uuid, default: "gen_random_uuid()", null: false, if_not_exists: true
    add_column :cm_guests, :other_organization, :string, if_not_exists: true
    add_column :cm_guests, :expectation, :string, if_not_exists: true
    add_column :cm_guests, :preferences, :text, if_not_exists: true
  end
end
