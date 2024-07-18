class AddBibNumberAndPrefixToCmGuests < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_guests, :bib_number, :string, if_not_exists: true
    add_column :cm_guests, :bib_number_prefix, :string, if_not_exists: true
  end
end
