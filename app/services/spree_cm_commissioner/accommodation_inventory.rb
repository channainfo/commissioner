module SpreeCmCommissioner
  class AccommodationInventory
    include SpreeCmCommissioner::InventoryFilterable

    attr_reader :variant_ids, :check_in, :check_out, :num_guests

    def initialize(variant_ids:, check_in:, check_out:, num_guests:)
      @variant_ids = variant_ids || []
      @check_in = check_in
      @check_out = check_out
      @num_guests = num_guests || 0
    end

    def fetch_inventory
      return [] unless valid_dates?

      grouped_inventories = inventory_items.group_by(&:variant_id)
      grouped_inventories.values.filter_map do |inventories|
        # I want to book 2 days, I have 3 people, the hotel tell me that, day1 has 5 room, but day2 has 2 room,
        # So if day 2 has 2 room, I may hesitate to book it. And the search result still show for user to see the option.
        inventories.min_by(&:quantity_available) if inventories.size == day_count &&
                                                    inventories.all? { |i| i.max_capacity >= num_guests &&
                                                                           i.quantity_available > 0 }
      end
    end

    private

    def inventory_items
      @inventory_items ||= fetch_inventory_items(variant_ids, check_in, check_out, product_type)
    end

    def day_count
      @day_count ||= (check_in..check_out.prev_day).count
    end

    def valid_dates?
      return false if check_in.blank? || check_out.blank?
      return false unless check_in.is_a?(Date) && check_out.is_a?(Date)
      return false if check_out <= check_in # Check-out must be after check-in
      return false if check_in < Date.today # Prevent past dates

      true
    end

    def product_type
      SpreeCmCommissioner::InventoryItem::PRODUCT_TYPE_ACCOMMODATION
    end
  end
end
