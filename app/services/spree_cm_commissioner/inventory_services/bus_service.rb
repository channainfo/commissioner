module SpreeCmCommissioner
  module InventoryServices
    class BusService < BaseService
      def fetch_inventory(trip_date)
        fetch_available_inventory('bus', trip_date, trip_date.next_day).first&.quantity_available || 0
      end

      private

      def service_type
        'bus'
      end
    end
  end
end
