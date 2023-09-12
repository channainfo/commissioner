class AddRejectedAtToSpreeLineItem < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_line_items, :rejected_at, :datetime, if_not_exists: true
    add_index :spree_line_items, :rejected_at, if_not_exists: true
  end
end
