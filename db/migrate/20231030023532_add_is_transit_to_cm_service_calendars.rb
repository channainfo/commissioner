class AddIsTransitToCmServiceCalendars < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_service_calendars, :is_transit, :boolean
  end
end
