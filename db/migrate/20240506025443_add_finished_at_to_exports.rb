class AddFinishedAtToExports < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_exports, :finished_at, :datetime, if_not_exists: true
  end
end
