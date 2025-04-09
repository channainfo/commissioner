class AddParentIdToCmPlace < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:cm_places, :parent_id)
      add_column :cm_places, :parent_id, :integer, null: true
      add_foreign_key :cm_places, :cm_places, column: :parent_id
      add_index :cm_places, :parent_id
    end
  end
end