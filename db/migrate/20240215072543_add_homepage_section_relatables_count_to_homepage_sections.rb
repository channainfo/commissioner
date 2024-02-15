class AddHomepageSectionRelatablesCountToHomepageSections < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_homepage_sections, :homepage_section_relatables_count, :integer, default: 0
  end
end
