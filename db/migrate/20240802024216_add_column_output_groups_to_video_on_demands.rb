class AddColumnOutputGroupsToVideoOnDemands < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_video_on_demands, :output_groups, :jsonb, default: {}, null: false
  end
end
