class AddRejectedByToSpreeLineItem < ActiveRecord::Migration[7.0]
  def change
    add_reference :spree_line_items, :rejected_by, foreign_key: { to_table: :spree_users }, index: true, if_not_exists: true
  end
end
