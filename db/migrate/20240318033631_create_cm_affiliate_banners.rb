class CreateCmAffiliateBanners < ActiveRecord::Migration[6.0]
  def change
    create_table :cm_affiliate_banners do |t|
      t.string :name
      t.string :url
      t.string :banner
      t.text :banner_text
      t.text :description
      t.date :start_date
      t.date :end_date
      t.string :status

      t.timestamps
    end
  end
end