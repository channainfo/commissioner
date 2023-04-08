module Spree
  module Admin
    module Merchant
      class AddressesController < Spree::Admin::Merchant::BaseController
        before_action :load_customer
        before_action :load_addresses

        def load_addresses
          @ship_address = customer.ship_address || customer.build_ship_address
          @bill_address = customer.bill_address || customer.build_bill_address

          @ship_address.country ||= current_store.default_country
          @bill_address.country ||= current_store.default_country
        end

        def load_customer
          customer
        end

        def customer
          @customer ||= SpreeCmCommissioner::Customer.find(params[:customer_id])
        end

        def model_class
          Spree::Address
        end

        def collection_url(options = {})
          admin_merchant_customer_addresses_url(options)
        end
      end
    end
  end
end
