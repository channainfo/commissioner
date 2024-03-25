module SpreeCmCommissioner
  class TripResult
    attr_accessor :trip_id, :vendor_id, :vendor_name, :short_name, :route_name,
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
      (departure_time.to_time + duration.to_i.seconds).strftime('%H:%M')
    end

    def duration_in_hms
      return 0 if duration.nil?

      hours = duration / 3600
      minutes = (duration % 3600) / 60
      seconds = duration % 60
      "#{hours}h #{minutes}m #{seconds}s"
    end
  end
end
