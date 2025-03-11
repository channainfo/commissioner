module SpreeCmCommissioner
  module BookingServices
    class BaseService
      def initialize(variant_id)
        @variant_id = variant_id
        @booking_query = BookingQuery.new(variant_id: variant_id, service_type: service_type)
      end

      def book_inventory(start_date, end_date, quantity)
        # Todo: need validation for quantity, start_date, and end_date
        booking_query.book_inventory(start_date, end_date, quantity)
      end

      private

      attr_reader :booking_query, :service_type

      def service_type
        raise "Need to define from sub class"
      end
    end
  end
end
