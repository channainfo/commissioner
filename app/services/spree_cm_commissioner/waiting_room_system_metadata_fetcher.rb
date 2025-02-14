require 'google/cloud/firestore'

module SpreeCmCommissioner
  class WaitingRoomSystemMetadataFetcher
    attr_reader :document_data

    def initialize(firestore: nil)
      @firestore = firestore if firestore.present?
    end

    def load_document_data
      @document_data = document.get.data
      CmAppLogger.log(label: 'Metadata document loaded successfully', data: @document_data)
    end

    def max_sessions_count
      @max_sessions_count ||= server_running_count * max_thread_count * multiplier / 100
    end

    def min_session_count
      @min_session_count ||= ENV.fetch('WAITING_ROOM_MIN_SESSIONS_COUNT', '5').to_i
    end

    def max_sessions_count_with_min
      @max_sessions_count_with_min ||= [max_sessions_count, min_session_count].max
      CmAppLogger.log(label: 'Max sessions count with min calculated', data: @max_sessions_count_with_min)
      @max_sessions_count_with_min
    end

    # firebase metadata

    def server_running_count
      count = document_data[:server_running_count]&.to_i || ENV.fetch('WAITING_ROOM_SERVERS_COUNT', '2').to_i
      CmAppLogger.log(label: 'Server running count fetched', data: count)
      count
    end

    def max_thread_count
      document_data[:max_thread_count]&.to_i || ENV.fetch('WAITING_ROOM_MAX_THREAD_COUNT', '10').to_i
    end

    # percentage
    def multiplier
      document_data[:multiplier]&.to_i || ENV.fetch('WAITING_ROOM_MULTIPLIER', '150').to_i
    end

    def document
      @document ||= firestore.col('metadata').doc('system')
    end

    def firestore
      @firestore ||= Google::Cloud::Firestore.new(project_id: service_account[:project_id], credentials: service_account)
    end

    def service_account
      @service_account ||= Rails.application.credentials.cloud_firestore_service_account
    end
  end
end
