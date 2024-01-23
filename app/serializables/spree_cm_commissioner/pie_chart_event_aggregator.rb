module SpreeCmCommissioner
  class PieChartEventAggregator
    attr_accessor :id, :type, :value

    def initialize(id:, type:, value:)
      @id = id
      @type = type
      @value = value
    end
  end
end
