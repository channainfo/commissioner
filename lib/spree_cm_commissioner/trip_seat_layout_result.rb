module SpreeCmCommissioner
  class TripSeatLayoutResult
    attr_accessor :trip_id, :total_sold, :total_seats, :remaining_seats, :allow_seat_selection, :layers

    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end
