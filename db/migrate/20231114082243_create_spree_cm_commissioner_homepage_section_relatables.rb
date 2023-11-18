class CreateSpreeCmCommissionerHomepageSectionRelatables < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_homepage_section_relatables do |t|
      t.references :homepage_section, null: false
      t.references :relatable, polymorphic: true, null: false
      t.integer :position
      t.boolean   :active, default: true

      t.timestamps
    end
  end
end
