class AddUuidToCmVideoOnDemand < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_video_on_demands, :uuid, :uuid, index: true, null: false
  end
end
