module SpreeCmCommissioner
  module Pricings
    class GuestOptions
      attr_reader :remaining_total_guests, :number_of_guests, :number_of_adults, :number_of_kids,
                  :allowed_extra_adults, :allowed_extra_kids, :allowed_total_adults, :allowed_total_kids,
                  :extra_adults, :extra_kids

      def initialize(options = {})
        @remaining_total_guests = options[:remaining_total_guests]
        @number_of_guests = options[:number_of_guests]
        @allowed_extra_adults = options[:allowed_extra_adults]
        @allowed_extra_kids = options[:allowed_extra_kids]
        @allowed_total_adults = options[:allowed_total_adults]
        @allowed_total_kids = options[:allowed_total_kids]
        @number_of_adults = options[:number_of_adults]
        @number_of_kids = options[:number_of_kids]
        @extra_adults = options[:extra_adults]
        @extra_kids = options[:extra_kids]
      end

      def self.from_line_item(line_item)
        GuestOptions.new(
          remaining_total_guests: line_item.remaining_total_guests,
          number_of_guests: line_item.number_of_guests,
          allowed_extra_adults: line_item.allowed_extra_adults,
          allowed_extra_kids: line_item.allowed_extra_kids,
          allowed_total_adults: line_item.allowed_total_adults,
          allowed_total_kids: line_item.allowed_total_kids,
          number_of_adults: line_item.number_of_adults,
          number_of_kids: line_item.number_of_kids,
          extra_adults: line_item.extra_adults,
          extra_kids: line_item.extra_kids
        )
      end

      def to_h
        {
          remaining_total_guests: remaining_total_guests,
          number_of_guests: number_of_guests,
          allowed_extra_adults: allowed_extra_adults,
          allowed_extra_kids: allowed_extra_kids,
          allowed_total_adults: allowed_total_adults,
          allowed_total_kids: allowed_total_kids,
          number_of_adults: number_of_adults,
          number_of_kids: number_of_kids,
          extra_adults: extra_adults,
          extra_kids: extra_kids
        }
      end
    end
  end
end
