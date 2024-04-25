module Spree
  module Billing
    class ReportController < Spree::Billing::BaseController
      before_action -> { parse_date!(params[:from_date]) }, only: [:show]
      before_action -> { parse_date!(params[:to_date]) }, only: [:show]

      rescue_from Date::Error, with: :redirect_to_default_params
      helper_method :permitted_report_attributes

      def show
        set_date_range_from_period
        @revenue_totals ||= revenue_report_query.reports_with_overdues
        @search = searcher.ransack(params[:q])
        @orders = @search.result.page(page).per(per_page)
      end

      def paid
        @search = Spree::Order.subscription.ransack(SpreeCmCommissioner::OrderParamsChecker.process_paid_params(params))
        @orders = @search.result.where(payment_state: 'paid').page(page).per(per_page)
      end

      def balance_due
        @search = Spree::Order.subscription.ransack(SpreeCmCommissioner::OrderParamsChecker.process_balance_due_params(params))
        @orders = @search.result.where(payment_state: 'balance_due').page(page).per(per_page)
      end

      def overdue
        @search = Spree::Order.subscription.joins(:line_items).where.not(payment_state: %w[paid failed])
                              .where('spree_line_items.due_date < ?', Time.zone.today)
                              .ransack(params[:q])
        @orders = @search.result.page(page).per(per_page)
      end

      def failed_orders
        @search = Spree::Order.subscription.joins(:line_items).where(payment_state: 'failed').ransack(params[:q])
        @orders = @search.result.page(page).per(per_page)
      end

      def active_subscribers
        @search = SpreeCmCommissioner::Customer.where('active_subscriptions_count > ?', 0).ransack(params[:q])
        @customers = @search.result.page(page).per(per_page)
      end

      def set_date_range_from_period
        today = Time.zone.today
        case params[:period]
        when 'this_month'
          fetch_date_range_for_this_month(today)
        when 'last_month'
          fetch_date_range_for_last_month(today)
        when 'this_week'
          fetch_date_range_for_this_week(today)
        when 'last_week'
          fetch_date_range_for_last_week(today)
        when 'this_quarter'
          fetch_date_range_for_this_quarter(today)
        when 'last_quarter'
          fetch_date_range_for_last_quarter(today)
        when 'this_year'
          fetch_date_range_for_this_year(today)
        when 'last_year'
          fetch_date_range_for_last_year(today)
        end
      end

      def print_all_invoices
        @orders = Spree::Order.subscription.joins(:invoice).where(payment_state: 'balance_due').where(cm_invoices: { vendor_id: current_vendor.id })

        @orders.each do |order|
          order.invoice.update(invoice_issued_date: Time.zone.today) if order.invoice.invoice_issued_date.blank?
        end
      end

      private

      def fetch_date_range_for_this_month(today)
        params[:from_date] = today.beginning_of_month
        params[:to_date] = today.end_of_month
      end

      def fetch_date_range_for_last_month(today)
        last_month = today - 1.month
        params[:from_date] = last_month.beginning_of_month
        params[:to_date] = last_month.end_of_month
      end

      def fetch_date_range_for_this_week(today)
        params[:from_date] = today.beginning_of_week
        params[:to_date] = today.end_of_week
      end

      def fetch_date_range_for_last_week(today)
        last_week = today - 1.week
        params[:from_date] = last_week.beginning_of_week
        params[:to_date] = last_week.end_of_week
      end

      def fetch_date_range_for_this_quarter(today)
        params[:from_date] = today.beginning_of_quarter
        params[:to_date] = today.end_of_quarter
      end

      def fetch_date_range_for_last_quarter(today)
        last_quarter = (today - 3.months).beginning_of_quarter
        params[:from_date] = last_quarter.beginning_of_quarter
        params[:to_date] = last_quarter.end_of_quarter
      end

      def fetch_date_range_for_this_year(today)
        params[:from_date] = today.beginning_of_year
        params[:to_date] = today.end_of_year
      end

      def fetch_date_range_for_last_year(today)
        last_year = today.prev_year
        params[:from_date] = last_year.beginning_of_year
        params[:to_date] = last_year.end_of_year
      end

      def revenue_report_query
        SpreeCmCommissioner::SubscriptionRevenueOverviewQuery.new(
          from_date: params[:from_date],
          to_date: params[:to_date],
          vendor_id: current_vendor.id
        )
      end

      def searcher
        @searcher ||= filter_with_type_params(
          SpreeCmCommissioner::SubscriptionOrdersQuery.new(
            from_date: params[:from_date],
            to_date: params[:to_date],
            vendor_id: current_vendor.id
          )
        )
      end

      # filter type with :payment_state.
      # included custom type: overdue
      def filter_with_type_params(query)
        case params[:type]
        when 'overdue'
          query.overdues
        when nil
          query.query_builder
        else
          query.query_builder.where(payment_state: params[:type])
        end
      end

      # redirect to last month
      def redirect_to_default_params
        from_date = Time.zone.today.beginning_of_month - 1.month
        to_date = from_date + 1.month

        redirect_to url_for(
          default_url_options.merge(
            from_date: from_date,
            to_date: to_date,
            type: params[:type] || :paid
          )
        )
      end

      def model_class
        Spree::Order
      end

      def permitted_resource_params
        params.require(:order).permit(permitted_report_attributes)
      end

      def permitted_report_attributes
        %i[from_date to_date vendor_id type]
      end
    end
  end
end
