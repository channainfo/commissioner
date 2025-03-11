module SpreeCmCommissioner
  module InventoryServices
    class AccommodationService < BaseService
      # Question: is the room available?
      # Scenario1: guest check website if King room available for 2 nights -> 1 room(1 guest) stay for 2 nights
      # Varinat - King room: should have Inventory unit 2 records(can be more for future?)
        # 1. Today: inventory_date - Date.today, quantity_available: 2, max_capacity: 3
        # 2. Tomorrow: inventory_date - Date.tomorrow, quantity_available: 1, max_capacity: 3
      # The search result: should display King room is available

      # Scenario2: guest check website if room King available for 2 nights -> 2 room(2 guest) stay for 2 nights
      # Varinat - King room: should have Inventory unit 2 records(can be more for future)
        # 1. Today: inventory_date - Date.today, quantity_available: 2, max_capacity: 3
        # 2. Tomorrow: inventory_date - Date.tomorrow, quantity_available: 1, max_capacity: 3
      # The search result: should display King room is available or not?

      # Guest should check if room available?, why check num_guests?

      # Assume: guest 1 => room1

      def fetch_inventory(check_in, check_out, num_guests)
        return nil unless valid_dates?(check_in, check_out)

        inventory = fetch_available_inventory(check_in, check_out)

        # Todo: not quite sure for this logic

        return nil unless inventory.size == (check_in..check_out.prev_day).count &&
                          inventory.all? { |i| i.max_capacity >= num_guests && i.quantity_available > 0 }
        inventory.map(&:quantity_available).min # Minimum available over range
      end

      private

      def valid_dates?(check_in, check_out)
        return false if check_in.blank? || check_out.blank?
        return false unless check_in.is_a?(Date) && check_out.is_a?(Date)
        return false if check_out <= check_in # Check-out must be after check-in
        return false if check_in < Date.today # Prevent past dates

        true
      end

      def service_type
        'accommodation'
      end
    end
  end
end
