require 'google/cloud/firestore'

# TODO: alert when available_slots is negative.
module SpreeCmCommissioner
  class WaitingGuestsCaller < BaseInteractor
    def call
      available_slots = fetch_available_slots
      CmAppLogger.log(label: 'Available slots', data: available_slots)
      return unless available_slots.positive?

      long_waiting_guests = fetch_long_waiting_guests(available_slots)
      CmAppLogger.log(label: 'Fetched long-waiting guests', data: long_waiting_guests.size)

      calling_all(long_waiting_guests)
      CmAppLogger.log(label: 'Updated guests to allow entering the room', data: long_waiting_guests.size)

      mark_as(full: long_waiting_guests.size >= available_slots, available_slots: available_slots - long_waiting_guests.size)
      CmAppLogger.log(label: 'Marked room status',
                      data: { full: long_waiting_guests.size >= available_slots, available_slots: available_slots - long_waiting_guests.size }
                     )
    end

    def fetch_available_slots
      max_sessions = fetch_max_sessions
      active_sessions = SpreeCmCommissioner::WaitingRoomSession.active.count
      available_slots = max_sessions - active_sessions
      CmAppLogger.log(label: 'Available slots', data: available_slots)
      available_slots
    end

    # This query required index. create them in Firebase beforehand.
    # Client side must create waiting_guests document with :queued_at & :allow_to_enter_room_at to null to allow filter & order.
    def fetch_long_waiting_guests(available_slots)
      firestore.col('waiting_guests')
               .doc(current_date)
               .col('records')
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

    def current_date
      Time.zone.now.strftime('%Y-%m-%d')
    end

    # When open app, app request to check whether room is full or not via Firebase instead of server to minimize server requests.
    def mark_as(full:, available_slots:)
      firestore.col('waiting_rooms').doc('lobby').set({ full: full, available_slots: available_slots })
    end

    def fetch_max_sessions
      fetcher = SpreeCmCommissioner::WaitingRoomSystemMetadataFetcher.new(firestore: firestore)
      fetcher.load_document_data

      fetcher.max_sessions_count_with_min
    end

    def firestore
      @firestore ||= Google::Cloud::Firestore.new(project_id: service_account[:project_id], credentials: service_account)
    end

    def service_account
      @service_account ||= Rails.application.credentials.cloud_firestore_service_account
    end
  end
end
