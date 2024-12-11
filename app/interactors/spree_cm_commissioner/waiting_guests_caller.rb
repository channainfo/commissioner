# TODO: alert when available_slots is negative.
module SpreeCmCommissioner
  class WaitingGuestsCaller < BaseInteractor
    def call
      available_slots = fetch_available_slots
      return unless available_slots.positive?

      long_waiting_guests = fetch_long_waiting_guests(available_slots)
      calling_all(long_waiting_guests)

      mark_as(full: long_waiting_guests.size >= available_slots, available_slots: available_slots - long_waiting_guests.size)
    end

    def fetch_available_slots
      max_sessions = fetch_max_sessions
      active_sessions = SpreeCmCommissioner::WaitingRoomSession.active.count
      max_sessions - active_sessions
    end

    # This query required index. create them in Firebase beforehand.
    # Client side must create waiting_guests document with :queued_at & :allow_to_enter_room_at to null to allow fillter & order.
    def fetch_long_waiting_guests(available_slots)
      FirestoreClient.instance.col('waiting_guests')
                     .where('allow_to_enter_room_at', '==', nil)
                     .order('queued_at')
                     .limit(available_slots)
                     .get.to_a
    end

    # For alert waiting guests to enter room, we just update :allow_to_enter_room_at.
    # App will listen to firebase & start refresh session token to enter room.
    def calling_all(waiting_guests)
      waiting_guests.each do |document|
        data = document.data.dup
        data[:allow_to_enter_room_at] = Time.zone.now
        document.ref.update(data)
      end
    end

    # When open app, app request to check whether room is full or not via Firebase instead of server to minimize server requests.
    def mark_as(full:, available_slots:)
      FirestoreClient.instance.col('waiting_rooms').doc('lobby').set({ full: full, available_slots: available_slots })
    end

    def fetch_max_sessions
      fetcher = SpreeCmCommissioner::WaitingRoomSystemMetadataFetcher.new
      fetcher.load_document_data

      fetcher.max_sessions_count_with_min
    end
  end
end
