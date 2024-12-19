class AddPagePathToCmWaitingRoomSessions < ActiveRecord::Migration[7.0]
  def change
    add_column :cm_waiting_room_sessions, :page_path, :string, if_not_exists: true
  end
end
