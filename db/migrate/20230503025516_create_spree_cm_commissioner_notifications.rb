class CreateSpreeCmCommissionerNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_notifications, if_not_exists: true do |t|
      t.references :recipient, polymorphic: true, null: false
      t.references :notificable, polymorphic: true, null: false
      t.jsonb :params
      t.string :type, null: false

      t.timestamps
    end
  end
end
