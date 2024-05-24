class CreateOperatorPlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_operator_places, if_not_exists: true do |t|
      t.integer :operator_id
      t.integer :place_id
      t.integer :stop_type
      t.boolean :is_active

      t.timestamps
    end
  end
end
