# rubocop:disable Layout/LineLength
module SpreeCmCommissioner
  class AccommodationSearch
    include ActiveModel::Validations
    attr_reader :from_date, :to_date, :province_id, :vendor_id, :num_guests

    MAX_QUERY_DAYS = 31

    validate :validate_date_range

    def initialize(from_date:, to_date:, province_id: nil, vendor_id: nil, num_guests: 1)
      @from_date = from_date
      @to_date = to_date
      @province_id = province_id
      @vendor_id = vendor_id
      @num_guests = num_guests
    end

    def with_available_inventory
      # Extract values for the temporary table
      values = inventory_units.map { |os| "(#{os.variant_id}, #{day_count}, #{os.quantity_available}, #{os.max_capacity - os.quantity_available})" }.join(',')

      # Query with multiple values
      scope = Spree::Vendor
        .joins("INNER JOIN spree_variants ON spree_variants.vendor_id = spree_vendors.id")
        .joins("INNER JOIN (VALUES #{values}) AS temp (variant_id, day, remaining, total_booking)
                ON spree_variants.id = temp.variant_id")
        .select('spree_vendors.*, spree_vendors.id as vendor_id, temp.variant_id, temp.day, temp.remaining, temp.total_booking')
        .where(spree_variants: { id: inventory_units.map(&:variant_id) })

      apply_filter(scope)
    end

    private

    def day_count
      (from_date..to_date.prev_day).count
    end

    # example: [{ variant_id: 637, quantity_available: 100, max_capacity: 0, inventory_date: null, service_type: "accommodation" }]
    def inventory_units
      @inventory_units ||= SpreeCmCommissioner::InventoryServices::AccommodationService.new(nil).with_available_inventory(from_date, to_date, num_guests)
    end

    def validate_date_range
      date_range = (to_date - from_date).to_i

      errors.add(:date_range, 'To Date cannot be less than From Date') if to_date < from_date
      errors.add(:date_range, "Duration must not be greater than #{MAX_QUERY_DAYS} days") if date_range > MAX_QUERY_DAYS
    end

    def apply_filter(scope)
      scope = scope.where(spree_vendors: { primary_product_type: :accommodation, state: :active })
      scope = scope.where(spree_vendors: { default_state_id: province_id }) if province_id.present?
      scope = scope.where(spree_vendors: { id: vendor_id }) if vendor_id.present?
      scope.distinct
    end
  end
end
# rubocop:enable Layout/LineLength
