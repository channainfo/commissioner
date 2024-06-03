module SpreeCmCommissioner
  module VariantAvailability
    class PermanentStockQuery
      attr_reader :variant, :from_date, :to_date, :except_line_item_id

      def initialize(variant:, from_date:, to_date:, except_line_item_id: nil)
        @variant = variant
        @from_date = from_date
        @to_date = to_date
        @except_line_item_id = except_line_item_id
      end

      def available?(quantity)
        (from_date..from_date).all? do |booking_date|
          booked_date_quantity[booking_date].nil? ||
            (booked_date_quantity[booking_date] - quantity) >= 0
        end
      end

      def booked_date_quantity
        dates_sql = ApplicationRecord.sanitize_sql_array(
          [
            'SELECT date FROM generate_series(?::date, ?::date, ?) AS date',
            from_date,
            to_date,
            date_interval
          ]
        )

        @booked_variants ||=
          Spree::LineItem
          .complete
          .select(
            '(SUM(spree_stock_items.count_on_hand) - SUM(spree_line_items.quantity)) AS available_quantity',
            'dates.date AS reservation_date'
          )
          .joins(variant: :stock_items)
          .where(variant_id: variant.id)
          .where.not(id: except_line_item_id)
          .joins("INNER JOIN (#{dates_sql}) dates ON dates.date >= spree_line_items.from_date AND dates.date < spree_line_items.to_date")
          .group(:variant_id, :reservation_date)
          .order(:reservation_date)
          .each_with_object({}) do |record, hash|
            hash[record.reservation_date.to_date] = record.available_quantity
          end
      end

      # override this for product that have
      # different date time interval than 1 day.
      def date_interval
        '1 day'
      end
    end
  end
end
