module SpreeCmCommissioner
  class WaitingRoomSystemMetadataFetcher
    attr_reader :document_data

    def load_document_data
      @document_data = document.get.data
    end

    def max_sessions_count
      @max_sessions_count ||= server_running_count * max_thread_count * multiplier / 100
    end

    def min_session_count
      @min_session_count ||= ENV.fetch('WAITING_ROOM_MIN_SESSIONS_COUNT', '5').to_i
    end

    def max_sessions_count_with_min
      @max_sessions_count_with_min ||= [max_sessions_count, min_session_count].max
    end

    # firebase metadata

    def server_running_count
      document_data[:server_running_count]&.to_i || ENV.fetch('WAITING_ROOM_SERVERS_COUNT', '2').to_i
    end

    def max_thread_count
      document_data[:max_thread_count]&.to_i || ENV.fetch('WAITING_ROOM_MAX_THREAD_COUNT', '10').to_i
    end

    # percentage
    def multiplier
      document_data[:multiplier]&.to_i || ENV.fetch('WAITING_ROOM_MULTIPLIER', '150').to_i
    end

    def document
      @document ||= FirestoreClient.instance.col('metadata').doc('system')
    end
  end
end
