class RemoveActiveFromHomepageSectionsRelatables < ActiveRecord::Migration[7.0]
  def change
    remove_column :cm_homepage_section_relatables, :active, :boolean, if_exists: true
  end
end
