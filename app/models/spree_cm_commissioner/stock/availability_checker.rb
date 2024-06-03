module SpreeCmCommissioner
  module Stock
    class AvailabilityChecker
      attr_reader :variant

      def initialize(variant)
        @variant = variant
      end

      def can_supply?(quantity = 1, options = {})
        return false unless variant.available?
        return true unless variant.should_track_inventory?
        return true if variant.backorderable?
        return true if variant.need_confirmation?

        if variant.permanent_stock?
          available_between_date_range?(quantity, options)
        else
          available?(quantity, options)
        end
      end

      def available?(quantity = 1, options = {})
        Spree::LineItem
          .complete
          .select('(SUM(spree_stock_items.count_on_hand) - SUM(spree_line_items.quantity)) AS available_quantity')
          .joins(variant: :stock_items)
          .where(variant_id: variant.id)
          .where.not(id: options[:except_line_item_id])
          .group(:variant_id)
          .all? { |record| record.available_quantity - quantity >= 0 }
      end

      # check availability on each date time.
      def available_between_date_range?(quantity = 1, options = {})
        date_series = construct_date_series(options[:from_date], options[:to_date])

        booked_variants =
          Spree::LineItem
          .complete
          .select(
            '(SUM(spree_stock_items.count_on_hand) - SUM(spree_line_items.quantity)) AS available_quantity',
            'd.date AS reservation_date'
          )
          .joins(variant: :stock_items)
          .where(variant_id: variant.id)
          .where.not(id: options[:except_line_item_id])
          .joins("INNER JOIN (#{date_series}) AS date) d ON d.date >= spree_line_items.from_date AND d.date < spree_line_items.to_date")
          .group(:variant_id, :reservation_date)
          .order(:reservation_date)
          .each_with_object({}) do |record, hash|
            hash[record.reservation_date.to_date] = record.available_quantity
          end

        (options[:from_date].to_date..options[:to_date].to_date).all? do |booking_date|
          booked_variants[booking_date].nil? || (booked_variants[booking_date] - quantity) >= 0
        end
      end

      def construct_date_series(from_date, to_date)
        "SELECT date FROM generate_series('#{from_date}'::date, '#{to_date}'::date, '#{date_interval}'"
      end

      # override this for product that have
      # different date time interval than 1 day.
      def date_interval
        '1 day'
      end
    end
  end
end
