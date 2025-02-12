class AddDateAndVariantIdToCmLineItemSeats < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_line_item_seats, :variant_id, :integer
    add_column :cm_line_item_seats, :date, :date
    add_index :cm_line_item_seats, [:variant_id, :date], name: 'index_cm_line_item_seats_on_variant_id_and_date'
  end
end
