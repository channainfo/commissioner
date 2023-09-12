class AddAcceptedAtToSpreeLineItem < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_line_items, :accepted_at, :datetime, if_not_exists: true
    add_index :spree_line_items, :accepted_at, if_not_exists: true
  end
end
