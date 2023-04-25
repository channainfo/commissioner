class CreateSpreeCmCommissionerNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_notifications do |t|
      t.references :recipient, polymorphic: true, null: false
      t.references :notificable, polymorphic: true, null: false
      t.jsonb :params

      t.timestamps
    end
  end
end
