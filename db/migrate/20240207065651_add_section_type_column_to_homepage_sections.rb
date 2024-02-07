class AddSectionTypeColumnToHomepageSections < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_homepage_sections, :section_type, :integer, default: 0
  end
end
