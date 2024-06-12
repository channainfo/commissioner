class AddNumberToSpreeLineItems < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_line_items, :number, :string, if_not_exists: true
  end
end
