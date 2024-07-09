class CreateCmUserPlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_user_places, if_not_exists: true do |t|
      t.references :user, foreign_key: { to_table: :spree_users }, index: true
      t.references :place, foreign_key: { to_table: :cm_places }, index: true

      t.timestamps
    end
  end
end
