module Spree
  module Admin
    module Merchant
      class CustomersController < Spree::Admin::Merchant::BaseController
        before_action :set_vendor, if: -> { member_action? }
        before_action :load_customer, if: -> { member_action? }

        protected

        def collection
          return @collection if defined?(@collection)

          @search = current_vendor.customers.ransack(params[:q])
          @collection = @search.result.page(page).per(per_page)
        end

        def load_customer
          @customer = @object
        end

        # @overrided
        def model_class
          SpreeCmCommissioner::Customer
        end

        def object_name
          'spree_cm_commissioner_customer'
        end

        # @overrided
        def collection_url(options = {})
          admin_merchant_customers_url(options)
        end

        def set_vendor
          permitted_resource_params[:vendor] = current_vendor
        end
      end
    end
  end
end
