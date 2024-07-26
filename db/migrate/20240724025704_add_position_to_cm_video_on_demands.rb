class AddPositionToCmVideoOnDemands < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_video_on_demands, :position, :integer, default: 0, if_not_exists: true
  end
end
