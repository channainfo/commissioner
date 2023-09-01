class AddRemarkToSpreeLineItem < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_line_items, :remark, :string, if_not_exists: true
  end
end
