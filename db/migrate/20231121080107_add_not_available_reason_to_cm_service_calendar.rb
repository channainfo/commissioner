class AddNotAvailableReasonToCmServiceCalendar < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_service_calendars, :not_available_reason, :text
  end
end
