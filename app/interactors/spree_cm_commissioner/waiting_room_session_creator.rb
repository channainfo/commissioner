require 'google/cloud/firestore'

module SpreeCmCommissioner
  class WaitingRoomSessionCreator < BaseInteractor
    delegate :remote_ip, :waiting_guest_firebase_doc_id, :page_path, to: :context

    def call
      if waiting_guest_firebase_doc_id.blank?
        CmAppLogger.log(label: 'Validation failed', data: 'waiting_guest_firebase_doc_id is blank')
        return context.fail!(message: 'must_provide_waiting_guest_firebase_doc_id')
      end

      if remote_ip.blank?
        CmAppLogger.log(label: 'Validation failed', data: 'remote_ip is blank')
        return context.fail!(message: 'must_provide_remote_ip')
      end

      if full?
        CmAppLogger.log(label: 'Validation failed', data: 'sessions have reached the maximum limit')
        return context.fail!(message: 'sessions_reach_it_maximum')
      end

      generate_jwt_token
      assign_token_and_create_session_to_db
      log_to_firebase

      # commented because of following bug: https://github.com/channainfo/commissioner/issues/2185
      # this job is already run every 1mn, disabling it still work.
      # call_other_waiting_guests
    end

    def full?
      fetcher = SpreeCmCommissioner::WaitingRoomSystemMetadataFetcher.new(firestore: firestore)
      fetcher.load_document_data

      current_sessions = SpreeCmCommissioner::WaitingRoomSession.active.size
      max_sessions = fetcher.max_sessions_count_with_min

      CmAppLogger.log(label: 'Session Info', data: { current_sessions: current_sessions, max_sessions: max_sessions })

      current_sessions >= max_sessions
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
      current_date = Time.zone.now.strftime('%Y-%m-%d')

      document = firestore.col('waiting_guests')
                          .doc(current_date)
                          .col('records')
                          .doc(waiting_guest_firebase_doc_id)

      data = document.get.data.dup
      data[:entered_room_at] = Time.zone.now
      data[:page_path] = page_path

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
