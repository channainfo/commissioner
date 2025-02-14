class AddServiceTypeToCmServiceCalendar < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_service_calendars, :service_type, :boolean
  end
end
