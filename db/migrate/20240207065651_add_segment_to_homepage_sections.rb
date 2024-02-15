class AddSegmentToHomepageSections < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_homepage_sections, :segment, :integer, default: 0
  end
end
