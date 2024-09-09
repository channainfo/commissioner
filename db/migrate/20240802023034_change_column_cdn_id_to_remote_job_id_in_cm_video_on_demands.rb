class ChangeColumnCdnIdToRemoteJobIdInCmVideoOnDemands < ActiveRecord::Migration[7.0]
  def change
    rename_column :cm_video_on_demands, :cdn_id, :remote_job_id
    change_column :cm_video_on_demands, :remote_job_id, :string, limit: 32
    add_index :cm_video_on_demands, :remote_job_id
  end
end
