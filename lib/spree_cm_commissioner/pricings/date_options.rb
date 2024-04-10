module SpreeCmCommissioner
  module Pricings
    class DateOptions
      attr_reader :date_index, :date_range, :date, :date_position

      def initialize(date_index:, date_range: [])
        @date_index = date_index
        @date_range = date_range
        @date = date_range[date_index]
        @date_position = date_index + 1
      end

      def to_h
        {
          date_index: date_index,
          date_range: date_range,
          date: date,
          date_position: date_position
        }
      end

      def ==(other)
        date_index == other.date_index &&
          date_range == other.date_range
      end
    end
  end
end
