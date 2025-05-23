module SpreeCmCommissioner
  class WaitingRoomSessionFirebaseLoggerJob < ApplicationJob
    def perform(options)
      room_session = SpreeCmCommissioner::WaitingRoomSession.find(options[:room_session_id])
      waiting_guest_firebase_doc_id = options[:waiting_guest_firebase_doc_id]

      SpreeCmCommissioner::WaitingRoomSessionFirebaseLogger.call(
        room_session: room_session,
        waiting_guest_firebase_doc_id: waiting_guest_firebase_doc_id
      )
    end
  end
end
