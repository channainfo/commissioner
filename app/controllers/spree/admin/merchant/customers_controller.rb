module Spree
  module Admin
    module Merchant
      class CustomersController < Spree::Admin::Merchant::BaseController
        before_action :set_vendor, if: -> { member_action? }
        before_action :load_customer, if: -> { member_action? }

        def collection
          return [] if current_vendor.blank?
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

        def location_after_save
          if permitted_resource_params.key?(:bill_address_attributes) && permitted_resource_params.key?(:ship_address_attributes)
            admin_merchant_customer_addresses_url(@customer)
          else
            edit_admin_merchant_customer_url(@customer)
          end
        end

        def set_vendor
          permitted_resource_params[:vendor] = current_vendor
        end
      end
    end
  end
end
