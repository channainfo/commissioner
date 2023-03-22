class AddExceptionRulesToCmServiceCalendars < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_service_calendars, :exception_rules, :jsonb, null: false, default: [], if_not_exists: true
  end
end
