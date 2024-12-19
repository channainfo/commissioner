require 'google/cloud/firestore'

module SpreeCmCommissioner
  class WaitingRoomSessionCreator < BaseInteractor
    delegate :remote_ip, :waiting_guest_firebase_doc_id, :page_path, to: :context

    def call
      return context.fail!(message: 'must_provide_waiting_guest_firebase_doc_id') if waiting_guest_firebase_doc_id.blank?
      return context.fail!(message: 'must_provide_remote_ip') if remote_ip.blank?
      return context.fail!(message: 'sessions_reach_it_maximum') if full?

      generate_jwt_token
      assign_token_and_create_session_to_db
      log_to_firebase

      call_other_waiting_guests
    end

    def full?
      fetcher = SpreeCmCommissioner::WaitingRoomSystemMetadataFetcher.new(firestore: firestore)
      fetcher.load_document_data

      SpreeCmCommissioner::WaitingRoomSession.active.size >= fetcher.max_sessions_count_with_min
    end

    def generate_jwt_token
      payload = { exp: expired_at.to_i }
      context.jwt_token = JWT.encode(payload, ENV.fetch('WAITING_ROOM_SESSION_SIGNATURE'), 'HS256')
    end

    def assign_token_and_create_session_to_db
      # create or renew
      context.room_session = SpreeCmCommissioner::WaitingRoomSession.where(guest_identifier: waiting_guest_firebase_doc_id).first_or_initialize
      context.room_session.assign_attributes(
        jwt_token: context.jwt_token,
        expired_at: expired_at,
        remote_ip: remote_ip,
        page_path: page_path
      )
      context.room_session.save!
    end

    def log_to_firebase
      document = firestore.col('waiting_guests').doc(waiting_guest_firebase_doc_id)

      data = document.get.data.dup
      data[:entered_room_at] = Time.zone.now

      document.update(data)
    end

    def call_other_waiting_guests
      SpreeCmCommissioner::WaitingGuestsCallerJob.perform_later
    end

    def expired_at
      expired_duration = ENV['WAITING_ROOM_SESSION_EXPIRE_DURATION_IN_SECOND']&.presence&.to_i || (60 * 3)
      context.expired_at ||= expired_duration.seconds.from_now
    end

    def firestore
      @firestore ||= Google::Cloud::Firestore.new(project_id: service_account[:project_id], credentials: service_account)
    end

    def service_account
      Rails.application.credentials.cloud_firestore_service_account
    end
  end
end
