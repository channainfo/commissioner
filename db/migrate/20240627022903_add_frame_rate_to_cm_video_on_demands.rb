class AddFrameRateToCmVideoOnDemands < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_video_on_demands, :frame_rate, :integer, null: false
  end
end
