class AddVideoProtocolToCmVideoOnDemands < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_video_on_demands, :video_protocol, :integer, default: 0, if_not_exists: true
  end
end
