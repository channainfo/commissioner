module SpreeCmCommissioner
  class EventTicketAggregator
    attr_accessor :id, :value

    def initialize(id:, value:)
      @id = id
      @value = value
    end
  end
end
