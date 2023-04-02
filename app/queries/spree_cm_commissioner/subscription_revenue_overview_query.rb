module SpreeCmCommissioner
  class SubscriptionRevenueOverviewQuery
    attr_reader :from_date, :to_date, :vendor_id, :current_date

    def initialize(from_date:, to_date:, vendor_id:, current_date: Time.zone.today)
      @from_date = from_date
      @to_date = to_date
      @vendor_id = vendor_id
      @current_date = current_date
    end

    def reports_with_overdues
      reports.concat(overdues)
      reports.sort_by { |report| report_types.index(report[:state]) || report_types.size }
    end

    def reports
      @reports ||= Spree::Order.subscription
                               .joins(:line_items)
                               .where(line_items: { vendor_id: vendor_id, from_date: from_date..to_date })
                               .group(:payment_state)
                               .select('payment_state AS state', *select_fields)
                               .map { |r| r.slice(:state, :orders_count, :total, :payment_total).symbolize_keys }
    end

    def overdues
      @overdues ||= SpreeCmCommissioner::SubscriptionOrdersQuery.new(
        from_date: from_date,
        to_date: to_date,
        vendor_id: vendor_id,
        current_date: current_date
      ).overdues.select(*select_fields).map do |report|
        report.slice(:orders_count, :total, :payment_total)
              .symbolize_keys
              .merge({ state: 'overdue' })
      end
    end

    private

    def select_fields
      ['COUNT(*) AS orders_count', 'SUM(total) AS total', 'SUM(payment_total) AS payment_total']
    end

    def report_types
      %w[paid balance_due overdue failed]
    end
  end
end
