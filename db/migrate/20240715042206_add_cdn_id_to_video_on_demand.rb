class AddCdnIdToVideoOnDemand < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_video_on_demands, :cdn_id, :string, if_not_exists: true
  end
end
