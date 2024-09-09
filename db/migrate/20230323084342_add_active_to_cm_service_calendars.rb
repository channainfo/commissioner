class AddActiveToCmServiceCalendars < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_service_calendars, :active, :boolean, default: true
  end
end
