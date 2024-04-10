module SpreeCmCommissioner
  module Pricings
    class Options
      attr_reader :total_quantity, :booking_date, :guest_options,
                  :date_options, :quantity_position, :pricing_rate_id, :rate_amount, :rate_currency

      def initialize( # rubocop:disable Metrics/ParameterLists
        total_quantity: nil,
        booking_date: nil,
        guest_options: nil,
        date_options: nil,
        quantity_position: nil,
        pricing_rate_id: nil,
        rate_amount: nil,
        rate_currency: nil
      )
        @total_quantity = total_quantity
        @booking_date = booking_date
        @guest_options = guest_options
        @date_options = date_options
        @quantity_position = quantity_position
        @pricing_rate_id = pricing_rate_id
        @rate_amount = rate_amount
        @rate_currency = rate_currency
      end

      def copy_with( # rubocop:disable Metrics/ParameterLists
        total_quantity: nil,
        booking_date: nil,
        guest_options: nil,
        date_options: nil,
        quantity_position: nil,
        pricing_rate_id: nil,
        rate_amount: nil,
        rate_currency: nil
      )
        self.class.new(
          total_quantity: total_quantity || self.total_quantity,
          booking_date: booking_date || self.booking_date,
          guest_options: guest_options || self.guest_options,
          date_options: date_options || self.date_options,
          quantity_position: quantity_position || self.quantity_position,
          pricing_rate_id: pricing_rate_id || self.pricing_rate_id,
          rate_amount: rate_amount || self.rate_amount,
          rate_currency: rate_currency || self.rate_currency
        )
      end

      def to_h
        {
          total_quantity: total_quantity,
          booking_date: booking_date,
          guest_options: guest_options.to_h,
          date_options: date_options.to_h,
          pricing_rate_id: pricing_rate_id,
          rate_amount: rate_amount,
          rate_currency: rate_currency
        }
      end
    end
  end
end
