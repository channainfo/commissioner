module SpreeCmCommissioner
  module BookingServices
    class EventService < BaseService
      def book(trip_date, quantity)
        book_inventory(trip_date, trip_date.next_day, quantity)
      end

      private

      def service_type
        "bus"
      end
    end
  end
end
