class AddStatusToVideoOnDemand < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_video_on_demands, :status, :integer, null: false, default: 0, if_not_exists: true
  end
end
