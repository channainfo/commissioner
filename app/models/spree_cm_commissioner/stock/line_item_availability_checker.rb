module SpreeCmCommissioner
  module Stock
    class LineItemAvailabilityChecker
      attr_reader :line_item

      def initialize(line_item)
        @line_item = line_item
      end

      def can_supply?(quantity)
        AvailabilityChecker.new(line_item.variant).can_supply?(quantity, options)
      end

      def options
        {
          from_date: line_item.from_date,
          to_date: line_item.to_date,
          except_line_item_id: line_item.id
        }
      end
    end
  end
end
