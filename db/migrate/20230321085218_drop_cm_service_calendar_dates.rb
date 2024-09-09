class DropCmServiceCalendarDates < ActiveRecord::Migration[7.0]
  def up
    drop_table :cm_service_calendar_dates, if_exists: true
  end
end
