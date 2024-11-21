module SpreeCmCommissioner
  class WaitingRoomSystemMetadataSetter
    def modify_max_thread_count(modify)
      fetcher.load_document_data

      max_thread_count = [fetcher.max_thread_count + modify, 1].max

      new_data = fetcher.document_data.dup
      new_data[:max_thread_count] = max_thread_count

      fetcher.document.set(new_data)
    end

    def modify_multiplier(modify)
      fetcher.load_document_data

      multiplier = [fetcher.multiplier + modify, 1].max

      new_data = fetcher.document_data.dup
      new_data[:multiplier] = multiplier

      fetcher.document.set(new_data)
    end

    def set(server_running_count:)
      fetcher.load_document_data

      new_data = fetcher.document_data.dup
      new_data[:server_running_count] = server_running_count

      fetcher.document.set(new_data)
    end

    def fetcher
      @fetcher ||= WaitingRoomSystemMetadataFetcher.new
    end
  end
end
