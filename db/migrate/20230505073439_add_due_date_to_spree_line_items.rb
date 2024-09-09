class AddDueDateToSpreeLineItems < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_line_items, :due_date, :timestamp, index: true, if_not_exists: true
  end
end