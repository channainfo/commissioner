class AddIndexToUuidInCmExports < ActiveRecord::Migration[7.0]
  def change
    change_column :cm_exports, :uuid, :string, limit: 36
    add_index :cm_exports, :uuid, unique: true
  end
end
