module SpreeCmCommissioner
  class ReservationVariantQuantityAvailabilityQuery
    attr_reader :variant_id, :from_date, :to_date

    def initialize(variant_id, from_date, to_date)
      @variant_id = variant_id
      @from_date = from_date
      @to_date = to_date
    end

    # {
    #   '2023-06-23': { :variant_id => 1, :permanent_stock => 3, :available_quantity => 0 },
    #   '2023-06-24': { :variant_id => 1, :permanent_stock => 3, :available_quantity => 2 },
    # }
    def booked_variants
      Spree::LineItem
        .joins(:order, :variant)
        .select(
          'spree_line_items.variant_id',
          'spree_variants.permanent_stock',
          '(spree_variants.permanent_stock - SUM(spree_line_items.quantity)) AS available_quantity',
          'd.date AS reservation_date'
        )
        .joins(date_range_by_date_unit)
        .where(order: { state: :complete })
        .where(variant_id: variant_id)
        .group(:variant_id, :permanent_stock, :reservation_date)
        .order(:reservation_date)
        .each_with_object({}) do |record, hash|
        hash[record.reservation_date.to_date] = record.slice(
          :variant_id,
          :permanent_stock,
          :available_quantity
        ).symbolize_keys
      end
    end

    private

    # only support accomodation.
    # should extend to support other reservation units like hours, week, etc.

    def date_range_by_date_unit
      "INNER JOIN (#{date_range_by_date_unit_series}) d ON d.date >= from_date AND d.date < to_date"
    end

    def date_range_by_date_unit_series
      "SELECT date FROM generate_series('#{from_date}'::date, '#{to_date}'::date, '1 day') AS date"
    end
  end
end
