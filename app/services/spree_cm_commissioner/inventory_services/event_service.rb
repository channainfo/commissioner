module SpreeCmCommissioner
  module InventoryServices
    class EventService < BaseService
      def fetch_inventory
        fetch_available_inventory('event', nil, nil).first&.quantity_available || 0
      end

      private

      def service_type
        'event'
      end
    end
  end
end
