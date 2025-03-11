module SpreeCmCommissioner
  module BookingServices
    class EventService < BaseService
      def book(quantity)
        book_inventory(nil, nil, quantity)
      end

      private

      def service_type
        "event"
      end
    end
  end
end
