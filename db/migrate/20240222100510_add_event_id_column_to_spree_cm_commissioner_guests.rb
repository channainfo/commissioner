class AddEventIdColumnToSpreeCmCommissionerGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_guests, :event_id, :integer

    SpreeCmCommissioner::Guest.all.each do |guest|
      guest.set_event_id
      guest.save
    end
  end
end
