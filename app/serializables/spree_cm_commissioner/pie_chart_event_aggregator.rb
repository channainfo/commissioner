module SpreeCmCommissioner
  class PieChartEventAggregator
    attr_accessor :id, :chart_type, :product_charts

    def initialize(id:, chart_type:, product_charts:)
      @id = id
      @chart_type = chart_type
      @product_charts = product_charts
    end
  end
end
