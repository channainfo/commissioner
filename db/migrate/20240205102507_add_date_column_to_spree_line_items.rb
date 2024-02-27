class AddDateColumnToSpreeLineItems < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_line_items, :date, :date
    add_index :spree_line_items, :date
  end
end
