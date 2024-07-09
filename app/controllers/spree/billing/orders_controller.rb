module Spree
  module Billing
    class OrdersController < Spree::Billing::BaseController
      include Spree::Admin::OrderConcern
      include Spree::Billing::OrderParentsConcern

      protected

      def scope
        if spree_current_user.has_spree_role?('admin')
          admin_scope
        else
          non_admin_scope
        end
      end

      # @overrided

      # override order method with @order
      attr_reader :order

      def collection
        return @collection if defined?(@collection)

        load_customer
        load_subscription
        filter_by_month(*default_date_range)

        @search = scope.ransack(params[:q])
        @collection = @search.result.includes(:subscription, :customer, :invoice).order(created_at: :desc).page(page).per(per_page)
      end

      def load_resource_instance
        return scope.new if new_actions.include?(action)

        scope.find_by!(number: params[:id])
      end

      def model_class
        Spree::Order
      end

      def object_name
        'order'
      end

      def default_date_range
        default_from_date = 6.months.ago.beginning_of_month
        default_to_date = Time.current.end_of_month
        [default_from_date, default_to_date]
      end

      def filter_by_month(default_from_date, default_to_date)
        params[:q] ||= {}
        if params[:month].present?
          date = Date.parse("#{params[:month]}-01")
          params[:q][:created_at_gteq] = date.beginning_of_month
          params[:q][:created_at_lteq] = date.end_of_month
        else
          params[:q][:created_at_gteq] = default_from_date
          params[:q][:created_at_lteq] = default_to_date
        end
      end

      private

      def admin_scope
        @subscription&.orders || @customer&.orders || current_vendor&.subscription_orders
      end

      def non_admin_scope
        place_ids = spree_current_user.place_ids
        filter_orders_by_place(@subscription&.orders, place_ids) ||
          filter_orders_by_place(@customer&.orders, place_ids) ||
          filter_orders_by_place(current_vendor&.subscription_orders, place_ids)
      end

      def filter_orders_by_place(orders, place_ids)
        return nil unless orders

        orders.joins(subscription: :customer).where(cm_customers: { place_id: place_ids })
      end
    end
  end
end
