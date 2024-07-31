module SpreeCmCommissioner
  class SubscriptionRevenueOverviewQuery
    attr_reader :from_date, :to_date, :vendor_id, :current_date, :spree_current_user

    def initialize(from_date:, to_date:, vendor_id:, spree_current_user:, current_date: Time.zone.today)
      @from_date = from_date
      @to_date = to_date
      @vendor_id = vendor_id
      @current_date = current_date
      @spree_current_user = spree_current_user
    end

    def reports_with_overdues
      all_reports = reports.concat(overdues)
      all_reports.sort_by { |report| report_types.index(report[:state]) || report_types.size }
    end

    def reports
      subquery ||= build_subquery

      Spree::Order.from(subquery, :orders)
                  .group(:payment_state)
                  .select('payment_state AS state', *select_fields)
                  .map { |r| r.slice(:state, :orders_count, :total, :payment_total).symbolize_keys }
    end

    def overdues
      subquery = build_subquery(overdue: true)

      Spree::Order.from(subquery, :orders)
                  .group(:payment_state)
                  .select(*select_fields)
                  .map do |report|
        report.slice(:orders_count, :total, :payment_total)
              .symbolize_keys
              .merge({ state: 'overdue' })
      end
    end

    private

    def build_subquery(overdue: false)
      base_query = Spree::Order.subscription
                               .joins(:line_items)
                               .where(line_items: { vendor_id: vendor_id, from_date: from_date..to_date })

      unless spree_current_user.has_spree_role?('admin')
        base_query = base_query.joins(subscription: :customer)
                               .where(cm_customers: { place_id: spree_current_user.place_ids })
      end

      if overdue
        base_query = base_query.where.not(payment_state: :paid)
                               .where('line_items.due_date < ?', current_date)
      end

      base_query.select('DISTINCT ON (spree_orders.id) spree_orders.*, line_items.*')
    end

    def select_fields
      ['COUNT(*) AS orders_count', 'SUM(total) AS total', 'SUM(payment_total) AS payment_total']
    end

    def report_types
      %w[paid balance_due overdue failed]
    end
  end
end
