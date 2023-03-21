class CreateServiceCalendarDates < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_service_calendar_dates, if_not_exists: true do |t|
      t.references :service_calendar, null: false
      t.date :date, null: false
      t.integer :exception_type, limit: 1, default: 1  # 1  means: (inclusion) Service has been added

      t.timestamps
    end
  end
end
