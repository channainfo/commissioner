class CreateCmSeatLayouts < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_seat_layouts do |t|
      t.integer :layout_type, default: 0
      t.string :layout_name
      t.integer :total_seats
      t.integer :sections
      t.integer :status, default: 0
      t.string :layoutable_type
      t.integer :layoutable_id
      t.timestamps
    end

    add_index :cm_seat_layouts, [:layoutable_type, :layoutable_id]
  end
end
