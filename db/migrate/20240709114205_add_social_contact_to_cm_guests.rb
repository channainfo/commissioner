class AddSocialContactToCmGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_guests, :social_contact_platform, :integer, if_not_exists: true
    add_column :cm_guests, :social_contact, :string, if_not_exists: true
  end
end
