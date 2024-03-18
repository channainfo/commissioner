class CreateAffiliateBanners < ActiveRecord::Migration[7.0]
  def change
    create_table :affiliate_banners do |t|
      t.string :name
      t.string :url
      t.string :banner
      t.integer :banner_clicks_count
      t.string :banner_text
      t.string :description
      t.string :status
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
