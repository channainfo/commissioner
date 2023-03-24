module Spree
  module Admin
    module Merchant
      class OrdersController < Spree::Admin::Merchant::BaseController
        before_action :load_order, if: -> { member_action? }

        protected

        def collection
          return @collection if defined?(@collection)

          @search = scope.ransack(params[:q])
          @collection = @search.result.page(page).per(per_page)
        end

        private

        def scope
          @scope = Spree::Order.unscoped.joins(:subscription => :customer).where(customer: { vendor_id: current_vendor })
        end

        def load_order
          @order = scope.includes(:adjustments).find_by!(number: params[:id])
          authorize! action, @order
        end

        # @overrided
        def model_class
          Spree::Order
        end

        def object_name
          'order'
        end

        # @overrided
        def collection_url(options = {})
          admin_merchant_orders_url(options)
        end
      end
    end
  end
end
