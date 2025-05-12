class CreateCmSeatSections < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_seat_sections do |t|
      t.string :layout_id
      t.string :section_name
      t.integer :row
      t.integer :column
      t.integer :seats

      t.timestamps
    end
  end
end
