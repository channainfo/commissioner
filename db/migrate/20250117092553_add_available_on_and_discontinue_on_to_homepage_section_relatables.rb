class AddAvailableOnAndDiscontinueOnToHomepageSectionRelatables < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_homepage_section_relatables, :available_on, :datetime, if_not_exists: true
    add_column :cm_homepage_section_relatables, :discontinue_on, :datetime, if_not_exists: true
  end
end
