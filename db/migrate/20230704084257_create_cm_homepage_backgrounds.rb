class CreateCmHomepageBackgrounds < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_homepage_backgrounds, if_not_exists: true do |t|
      t.string :title
      t.string :app_image
      t.string :web_image
      t.string :redirect_url
      t.boolean :active, default: true
      t.integer :priority
      t.datetime :deleted_at
      
      t.timestamps
    end
  end
end
