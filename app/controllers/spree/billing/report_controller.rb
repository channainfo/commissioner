module Spree
  module Billing
    class ReportController < Spree::Billing::BaseController
      before_action -> { parse_date!(params[:from_date]) }
      before_action -> { parse_date!(params[:to_date]) }

      rescue_from Date::Error, with: :redirect_to_default_params
      helper_method :permitted_report_attributes

      def show
        @revenue_totals ||= revenue_report_query.reports_with_overdues

        @search = searcher.ransack(params[:q])
        @orders = @search.result.page(page).per(per_page)
      end

      private

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
