class CreateCmPlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_places, if_not_exists: true do |t|
      t.string :reference
      t.string :name
      t.text :vicinity
      t.decimal :lat, precision: 11, scale: 8
      t.decimal :lon, precision: 11, scale: 8
      t.string :icon
      t.string :url
      t.decimal :rating, precision: 4, scale: 2
      t.string :formatted_phone_number
      t.text :formatted_address
      t.text :address_components
      t.text :types
      t.index :reference

      t.timestamps
    end
  end
end
