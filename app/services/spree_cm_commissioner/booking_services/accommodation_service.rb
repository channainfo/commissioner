module SpreeCmCommissioner
  module BookingServices
    class AccommodationService < BaseService
      def book(check_in, check_out, num_room)
        book_inventory(check_in, check_out, num_room)
      end

      private

      def service_type
        "accommodation"
      end
    end
  end
end
