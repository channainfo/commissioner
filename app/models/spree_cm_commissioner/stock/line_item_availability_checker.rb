module SpreeCmCommissioner
  module Stock
    class LineItemAvailabilityChecker
      attr_reader :line_item

      def initialize(line_item)
        @line_item = line_item
      end

      def can_supply?(quantity)
        ::SpreeCmCommissioner::Stock::AvailabilityChecker.new(line_item.variant, options)
                                                         .can_supply?(quantity)
      end

      def options
        {
          from_date: line_item.from_date,
          to_date: line_item.to_date
        }
      end
    end
  end
end
