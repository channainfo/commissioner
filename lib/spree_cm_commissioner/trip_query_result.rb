module SpreeCmCommissioner
  class TripQueryResult
    attr_reader :trips, :connection_id

    def initialize(trips, connection_id: nil)
      @trips = Array(trips)
      @connection_id = connection_id
    end

    def direct?
      @trips.size == 1
    end
  end
end
