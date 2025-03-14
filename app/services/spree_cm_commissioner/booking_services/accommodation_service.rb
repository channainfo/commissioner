module SpreeCmCommissioner
  module BookingServices
    class AccommodationService < BaseService
      def book(check_in, check_out, num_room)
        validate_dates(check_in, check_out)

        book_inventory(check_in, check_out, num_room)
      end

      private

      def service_type
        "accommodation"
      end

      def validate_dates(check_in, check_out)
        unless check_in && check_out && check_out > check_in
          raise ArgumentError, "Check-out date must be after check-in date"
        end
      end
    end
  end
end
