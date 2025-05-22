require 'google/cloud/firestore'

module SpreeCmCommissioner
  class WaitingRoomSessionFirebaseLogger < BaseInteractor
    delegate :room_session, :waiting_guest_firebase_doc_id, to: :context

    def call
      current_date = room_session.created_at.strftime('%Y-%m-%d')
      document = firestore.col('waiting_guests')
                          .doc(current_date)
                          .col('records')
                          .doc(waiting_guest_firebase_doc_id)

      data = document.get.data.dup
      data[:entered_room_at] = room_session.created_at
      data[:page_path] = room_session.page_path
      data[:tenant_id] = room_session.tenant_id

      document.update(data)
    end

    def firestore
      @firestore ||= Google::Cloud::Firestore.new(project_id: service_account[:project_id], credentials: service_account)
    end

    def service_account
      Rails.application.credentials.cloud_firestore_service_account
    end
  end
end
