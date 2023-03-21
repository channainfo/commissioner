module Spree
  module Admin
    module Calendars
      class OrdersController < Spree::Admin::Calendars::BaseController
        def collection
          # for whole month calendar
          from = active_date.beginning_of_month - 1.week
          to = active_date.end_of_month + 1.week

          @collection ||= Spree::Order.where.not(state: :cart)
                                      .joins(:line_items)
                                      .where(line_items: { from_date: from..to, vendor_id: params[:vendor_id] })
        end

        # @overrided
        def model_class
          Spree::Order
        end

        # @overrided
        def object_name
          'order'
        end
      end
    end
  end
end
