class AddColumnCompletedAtToCmVideoOnDemands < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_video_on_demands, :completed_at, :datetime, null: true
  end
end
