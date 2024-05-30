class CreateCmGoogleWallets < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_google_wallets, if_not_exists: true do |t|
      t.string :class_id
      t.string :type
      t.integer :review_status, default: 0 , null: false
      t.text :preferences
      t.references :product
      t.index :class_id, unique: true
      t.timestamps
    end
  end
end
