module Spree
  module Billing
    class ReportsController < Spree::Billing::BaseController
      before_action -> { parse_date!(params[:from_date]) }, only: [:index]
      before_action -> { parse_date!(params[:to_date]) }, only: [:index]

      rescue_from Date::Error, with: :redirect_to_default_params
      helper_method :permitted_report_attributes

      rescue_from SpreeCmCommissioner::ExceedingRangeError, with: :handle_exceeding_range

      def index
        (from_date, to_date) = date_range_for_month
        @revenue_totals = revenue_report_query(from_date, to_date).reports_with_overdues
        @search = searcher(from_date, to_date).ransack(params[:q])
        @orders = @search.result.includes(:line_items).page(page).per(per_page)
      end

      # GET /billing/reports/paid
      def paid
        @search = Spree::Order.subscription.ransack(SpreeCmCommissioner::OrderParamsChecker.process_paid_params(params))
        @orders = @search.result.includes(:line_items).where(payment_state: 'paid').page(page).per(per_page)
      end

      # GET /billing/reports/balance_due
      def balance_due
        @search = Spree::Order.subscription.ransack(SpreeCmCommissioner::OrderParamsChecker.process_balance_due_params(params))
        @orders = @search.result.includes(:line_items).where(payment_state: 'balance_due').page(page).per(per_page)
      end

      # GET /billing/reports/overdue
      def overdue
        @search = Spree::Order.subscription.joins(:line_items).where.not(payment_state: %w[paid failed])
                              .where('spree_line_items.due_date < ?', Time.zone.today)
                              .ransack(params[:q])
        @orders = @search.result.page(page).per(per_page)
      end

      # GET /billing/reports/failed_orders
      def failed_orders
        @search = Spree::Order.subscription.joins(:line_items).where(payment_state: 'failed').ransack(params[:q])
        @orders = @search.result.page(page).per(per_page)
      end

      # GET /billing/reports/active_subscribers
      def active_subscribers
        @search = SpreeCmCommissioner::Customer.joins(:taxons).where('active_subscriptions_count > ?', 0).ransack(params[:q])
        @customers = @search.result.includes(:subscriptions, :taxons).page(page).per(per_page)
      end

      # POST /billing/reports/print_all_invoices
      def print_all_invoices
        @orders = Spree::Order.subscription.joins(:invoice).where(payment_state: 'balance_due').where(cm_invoices: { vendor_id: current_vendor.id })

        @orders.each do |order|
          order.invoice.update(invoice_issued_date: Time.zone.today) if order.invoice.invoice_issued_date.blank?
        end
      end

      private

      def handle_exceeding_range
        flash[:error] = Spree.t('billing.exceeding_date_range')

        redirect_to billing_report_path
      end

      def date_range_for_month
        if params[:period].present?
          today = Time.zone.today
          month = params[:period]
          from_date = Time.zone.local(today.year, month.to_i, 1).beginning_of_day
          to_date = Time.zone.local(today.year, month.to_i, 31).end_of_day
          [from_date, to_date]
        else
          from_date = params[:from_date]
          to_date = params[:to_date]
          raise SpreeCmCommissioner::ExceedingRangeError if (to_date.to_date - from_date.to_date).to_i > 180
        end
      end

      def revenue_report_query(from_date, to_date)
        SpreeCmCommissioner::SubscriptionRevenueOverviewQuery.new(
          from_date: from_date,
          to_date: to_date,
          vendor_id: current_vendor.id
        )
      end

      def searcher(from_date, to_date)
        @searcher ||= filter_with_type_params(
          SpreeCmCommissioner::SubscriptionOrdersQuery.new(
            from_date: from_date,
            to_date: to_date,
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
