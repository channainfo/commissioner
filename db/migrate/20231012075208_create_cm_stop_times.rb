class CreateCmStopTimes < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_stop_times do |t|
      t.string :reference
      t.integer :trip_id
      t.integer :stop_id
      t.integer :next_stop_time_id
      t.integer :arrival_time
      t.integer :departure_time
      t.integer :sequence
      t.datetime :created_at
      t.datetime :updated_at
      t.integer :number_of_seat
      t.text  :layouts
      t.string :amenities
      t.integer :vehicle_type_id
      t.integer :location_id
      t.string  :signature
      t.string  :external_ref
      t.integer :route_type
      t.integer :main_stop_time_id
      t.integer :operator_id
      t.integer :transfer_from
      t.integer :duration
      t.datetime :deleted_at
      t.boolean :skip_must_select_intermediate_stop_seat, default: false
      t.boolean :is_transfer, default: false
      t.boolean :is_gender_sensitivity, default: false
      t.boolean :disallow_pickup, default: false
      t.integer :offset_day
    end
  end
end
