module Spree
  module Admin
    module Calendars
      class ListingPricesController < Spree::Admin::Calendars::BaseController
        def collection
          @collections = listing_prices
        end

        def listing_prices
          return [] if vendor.nil?

          activator.vendor_listing_prices
        end

        def activator
          return @activator if defined?(@activator)

          from = active_date.beginning_of_month - 1.week
          to = active_date.end_of_month + 1.week

          @activator = SpreeCmCommissioner::VendorPriceRulesActivator.call(
            from_date: from.to_s,
            to_date: to.to_s,
            vendor_id: params[:vendor_id]
          )
        end

        def vendor
          @vendor ||= Spree::Vendor.find(params[:vendor_id])
        end

        # @overrided
        def model_class
          SpreeCmCommissioner::ListingPrice
        end

        # @overrided
        def object_name
          'spree_cm_commissioner_listing_price'
        end

        # @overrided
        def collection_url(options = {})
          admin_calendars_listing_prices_url(options)
        end
      end
    end
  end
end
