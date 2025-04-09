class AddHideVideoBannerToSpreeTaxon < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_taxons, :hide_video_banner, :boolean, default: false, if_not_exists: true
  end
end
