class AddSlugToVideoOnDemand < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_video_on_demands, :slug, :string, if_not_exists: true
  end
end
