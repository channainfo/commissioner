class CreateCmLineItemSeats < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_line_item_seats, if_not_exists: true do |t|
      t.integer :line_item_id
      t.integer :seat_id

      t.timestamps
    end
  end
end
