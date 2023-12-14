class CreateSpreeCmCommissionerGuests < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_guests, if_not_exists: true do |t|
      t.string :first_name
      t.string :last_name
      t.integer :occupation , default: 0
      t.date :dob
      t.integer :gender, default: 0

      t.timestamps
    end
  end
end
