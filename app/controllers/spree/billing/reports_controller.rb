module Spree
  module Billing
    class ReportsController < Spree::Billing::BaseController
      include SpreeCmCommissioner::Billing::MonthlyOrdersHelper

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
        @search = orders_scope.ransack(SpreeCmCommissioner::OrderParamsChecker.process_paid_params(params))
        @orders = @search.result.includes(:line_items).where(payment_state: 'paid').page(page).per(per_page)
      end

      # GET /billing/reports/balance_due
      def balance_due
        @search = orders_scope.ransack(SpreeCmCommissioner::OrderParamsChecker.process_balance_due_params(params))
        @orders = @search.result.includes(:line_items).where(payment_state: 'balance_due').page(page).per(per_page)

        respond_to do |format|
          format.html
          format.js
        end
      end

      # GET /billing/reports/overdue
      def overdue
        @search = orders_scope.joins(:line_items).where.not(payment_state: %w[paid failed])
                              .where('spree_line_items.due_date < ?', Time.zone.today)
                              .ransack(params[:q])
        @orders = @search.result.includes(:line_items).page(page).per(per_page)
      end

      # GET /billing/reports/failed_orders
      def failed_orders
        @search = orders_scope.joins(:line_items).where(payment_state: 'failed')
                              .ransack(params[:q])
        @orders = @search.result.includes(:line_items).page(page).per(per_page)
      end

      # GET /billing/reports/active_subscribers
      def active_subscribers
        load_bussinesses

        @search = customers_scope.ransack(params[:q])
        @customers = @search.result.includes(:subscriptions, :taxons).page(page).per(per_page)
      end

      # POST /billing/reports/print_all_invoices
      def print_all_invoices
        @orders = orders_scope.joins(:invoice).where(payment_state: 'balance_due').where(cm_invoices: { vendor_id: current_vendor.id })

        @orders.each do |order|
          order.invoice.update(invoice_issued_date: Time.zone.today) if order.invoice.invoice_issued_date.blank?
        end
      end

      def export
        @year = params[:year].presence || Time.zone.today.year
        search = orders_scope.where(payment_state: %w[paid balance_due failed]).joins(:invoice)
                             .where('EXTRACT(YEAR FROM cm_invoices.date) = ?', @year).ransack(params[:q]).result

        order_hashes = load_orders_by_month(search, @year)
        @orders = order_hashes[:orders]

        @total = order_hashes[:total]
        @current_month_total = order_hashes[:current_month_total]
        @previous_month_carried_forward = order_hashes[:previous_month_carried_forward]
        @paid = order_hashes[:paid]
        @balance_due = order_hashes[:balance_due]
        @voided = order_hashes[:voided]

        return unless request.format == :csv

        csv_data = SpreeCmCommissioner::Exports::ExportOrderCsvService.new(@orders[params[:month].to_i], params[:place_id]).call

        respond_to do |format|
          format.csv do
            send_data csv_data, filename: "#{@year}_#{Date::MONTHNAMES[params[:month].to_i]}_Invoices.csv", type: 'text/csv; charset=utf-8'
          end
        end
      end

      private

      def load_bussinesses
        @businesses = Spree::Taxonomy.businesses.taxons.where('depth > ? ', 1).order('parent_id ASC').uniq
      end

      def orders_scope
        if spree_current_user.has_spree_role?('admin')
          Spree::Order.subscription
        else
          Spree::Order.subscription
                      .joins(subscription: :customer)
                      .where(cm_customers: { place_id: spree_current_user.place_ids })
        end
      end

      def customers_scope
        if spree_current_user.has_spree_role?('admin')
          SpreeCmCommissioner::Customer.joins(:taxons).where('active_subscriptions_count > ?', 0)
        else
          @search = SpreeCmCommissioner::Customer.joins(:taxons).where('active_subscriptions_count > ?', 0)
                                                 .where(cm_customers: { place_id: spree_current_user.place_ids })
        end
      end

      def handle_exceeding_range
        flash[:error] = Spree.t('billing.exceeding_date_range')

        redirect_to billing_report_path
      end

      def date_range_for_month
        if params.dig(:spree_cm_commissioner_report, :use_custom_date_range) == '1'
          from_date = params[:from_date]
          to_date = params[:to_date]
          raise SpreeCmCommissioner::ExceedingRangeError if (to_date.to_date - from_date.to_date).to_i > 180
        elsif params[:period].present?
          today = Time.zone.today
          month = params[:period]
          year = (params[:year].presence || today.year)
          from_date = Time.zone.local(year, month.to_i, 1).beginning_of_day
          to_date = Time.zone.local(year, month.to_i, 31).end_of_day
        end
        [from_date, to_date]
      end

      def revenue_report_query(from_date, to_date)
        SpreeCmCommissioner::SubscriptionRevenueOverviewQuery.new(
          from_date: from_date,
          to_date: to_date,
          vendor_id: current_vendor.id,
          spree_current_user: spree_current_user
        )
      end

      def searcher(from_date, to_date)
        @searcher ||= filter_with_type_params(
          SpreeCmCommissioner::SubscriptionOrdersQuery.new(
            from_date: from_date,
            to_date: to_date,
            vendor_id: current_vendor.id,
            spree_current_user: spree_current_user
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
        %i[from_date to_date vendor_id type month year]
      end
    end
  end
end
