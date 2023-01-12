class AddFieldsToSpreeLineItems < ActiveRecord::Migration[6.1]
  def change
    change_table :spree_line_items, bulk: true do |t|
      t.datetime :from_date
      t.datetime :to_date
      t.integer :vendor_id
      t.string :option_type
      t.index [:from_date, :to_date], name: 'line_item_date_range'
      t.index :vendor_id
    end
  end
end
