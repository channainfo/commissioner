module SpreeCmCommissioner
  class VendorQuery
    include ActiveModel::Validations
    attr_reader :from_date, :to_date, :province_id, :vendor_id
    MAX_QUERY_DAYS = 31

    validate :validate_date_range

    def initialize(from_date:, to_date:, province_id: nil, vendor_id: nil)
      @from_date = from_date
      @to_date = to_date
      @province_id = province_id
      @vendor_id = vendor_id
    end

    def date_list_sql
      end_date = to_date - 1.days
      "SELECT day FROM generate_series('#{from_date}'::date, '#{end_date}', '1 day') AS day"
    end

    def booked_vendors
      # Query to get all vendors group by day that have booking overlaps with from_date and start_date
      # Results: vendor_id, day, total_booking
      scope = Spree::Vendor.select('spree_vendors.id AS vendor_id, date_list.day AS day, sum(line_items.quantity) AS total_booking')
              .joins('INNER JOIN spree_line_items line_items ON line_items.vendor_id = spree_vendors.id')
              .joins("INNER JOIN (#{date_list_sql}) date_list ON day >= line_items.from_date AND day <= line_items.to_date")
              .where(['(line_items.from_date <= day AND day <= line_items.to_date)'])

      scope = apply_filter(scope)
      scope.group('spree_vendors.id, day')
    end

    def max_booked_vendor_sql
      "SELECT DISTINCT ON (vendor_id) vendor_id, day, total_booking FROM (#{booked_vendors.to_sql}) AS booked_vendors ORDER BY vendor_id, total_booking DESC"
    end

    def vendor_with_available_inventory
      # Get vendors by province that include: day, total_booking and remaining
      scope = Spree::Vendor.select('spree_vendors.*, vendor_id, day, COALESCE(total_booking, 0) AS total_booking, COALESCE((spree_vendors.total_inventory - max_booked_vendors.total_booking), spree_vendors.total_inventory) AS remaining')
                .joins("LEFT JOIN (#{max_booked_vendor_sql}) max_booked_vendors ON max_booked_vendors.vendor_id = spree_vendors.id")
      apply_filter(scope)
    end

    private

    def validate_date_range
      date_range = (to_date - from_date).to_i

      errors.add(:date_range, "To Date cannot be less than From Date")      if to_date < from_date
      errors.add(:date_range, "Duration must not be greater than #{MAX_QUERY_DAYS} days")  if date_range > MAX_QUERY_DAYS
    end

    def apply_filter(scope)
      scope = scope.where(['spree_vendors.state_id = ?', province_id]) if province_id.present?
      scope = scope.where(['spree_vendors.id = ?', vendor_id]) if vendor_id.present?
      scope
    end
  end
end