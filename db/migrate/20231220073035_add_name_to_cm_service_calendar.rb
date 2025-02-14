class AddNameToCmServiceCalendar < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_service_calendars, :name, :string, if_not_exists: true
  end
end
