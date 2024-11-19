class CreateCmWaitingRoomSessions < ActiveRecord::Migration[7.0]
  def change
    create_table :cm_waiting_room_sessions, if_not_exists: true do |t|
      t.string :guest_identifier, null: false
      t.string :jwt_token, null: false
      t.string :remote_ip
      t.datetime :expired_at, null: false

      t.timestamps
    end

    # guest_identifier is firebase document ID or user waiting ID. Each user should have only one of it. We store it to user device once set.
    # So we can renew user sessinos with it.
    add_index :cm_waiting_room_sessions, :guest_identifier, unique: true, if_not_exists: true
    add_index :cm_waiting_room_sessions, :expired_at, if_not_exists: true
  end
end
