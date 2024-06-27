class AddVideoQualityToCmVideoOnDemands < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_video_on_demands, :video_quality, :integer, default: 0, if_not_exists: true
  end
end
