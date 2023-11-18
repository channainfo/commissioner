class CreateSpreeCmCommissionerHomepageSections < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_homepage_sections do |t|
      t.string    :title, null: false
      t.string    :description
      t.integer   :position
      t.boolean   :active, default: true

      t.timestamps
    end
  end
end
