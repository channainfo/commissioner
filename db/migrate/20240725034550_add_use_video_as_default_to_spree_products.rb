class AddUseVideoAsDefaultToSpreeProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_products, :use_video_as_default, :boolean, default: false, if_not_exists: true
  end
end
