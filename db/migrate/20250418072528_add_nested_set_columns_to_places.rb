class AddNestedSetColumnsToPlaces < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_places, :parent_id, :integer if !column_exists?(:cm_places, :parent_id)
    add_column :cm_places, :lft,       :integer if !column_exists?(:cm_places, :lft)
    add_column :cm_places, :rgt,       :integer if !column_exists?(:cm_places, :rgt)

    add_column :cm_places, :depth,          :integer if !column_exists?(:cm_places, :depth)
    add_column :cm_places, :children_count, :integer if !column_exists?(:cm_places, :children_count)
  end
end
