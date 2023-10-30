class AddNameToCmServiceCalendars < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_service_calendars, :name, :string
  end
end
