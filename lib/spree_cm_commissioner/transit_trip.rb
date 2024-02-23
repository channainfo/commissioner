module SpreeCmCommissioner
  class TransitTrip
    attr_accessor :trip_id, :vendor_id, :vendor_name, :route_name,
                  :origin_id, :origin, :destination_id, :destination,
                  :total_sold, :total_seats,
                  :duration, :vehicle, :departure_time

    def initialize(trip_id:, vendor_id:, vendor_name:, route_name:, # rubocop:disable Metrics/ParameterLists
                   origin_id:, origin:, destination_id:, destination:,
                   total_sold:, total_seats:
    )
      @trip_id = trip_id
      @vendor_id = vendor_id
      @vendor_name = vendor_name
      @route_name = route_name
      @origin_id = origin_id
      @origin = origin
      @destination_id = destination_id
      @destination = destination
      @total_sold = total_sold
      @total_seats = total_seats
    end

    def remaining_seats
      total_seats - total_sold
    end

    def set_option_value(attr_type:, option_value:)
      case attr_type
      when 'duration'
        @duration = option_value
      when 'vehicle'
        @vehicle = option_value
      when 'departure_time'
        @departure_time = option_value
      end
    end
  end
end
