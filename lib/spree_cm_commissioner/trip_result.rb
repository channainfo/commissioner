module SpreeCmCommissioner
  class TripResult
    attr_accessor :trip_id, :vendor_id, :vendor_name, :route_name,
                  :origin_id, :origin, :destination_id, :destination,
                  :total_sold, :total_seats,
                  :duration, :vehicle_id, :departure_time

    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def remaining_seats
      total_seats - total_sold
    end

    def arrival_time
      departure_time.to_time + duration.to_i.hours
    end
  end
end
