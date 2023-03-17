class CreateServiceCalendars < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_service_calendars, if_not_exists: true do |t|
      t.references :calendarable, polymorphic: true, null: false, index: true
      t.boolean :monday,    default: true
      t.boolean :tuesday,   default: true
      t.boolean :wednesday, default: true
      t.boolean :thursday,  default: true
      t.boolean :friday,    default: true
      t.boolean :saturday,  default: true
      t.boolean :sunday,    default: true
      t.date :start_date
      t.date :end_date

      t.timestamps
    end

  end
end
