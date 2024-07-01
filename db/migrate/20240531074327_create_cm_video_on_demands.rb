class CreateCmVideoOnDemands < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_video_on_demands, if_not_exists: true do |t|
          t.string :title

          t.text :description

          t.references :variant, foreign_key: { to_table: :spree_variants }, null: false

          t.timestamps
    end
  end
end
