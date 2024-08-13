class AddBibIndexToCmGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_guests, :bib_index, :string, if_not_exists: true
    add_index :cm_guests, :bib_index,
              unique: true,
              where: "bib_index IS NOT NULL AND bib_index <> ''",
              if_not_exists: true
  end
end
