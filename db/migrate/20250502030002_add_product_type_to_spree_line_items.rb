class AddProductTypeToSpreeLineItems < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_line_items, :product_type, :integer, if_not_exists: true
  end
end
