module SpreeCmCommissioner
  module Admin
    module OrdersControllerDecorator
      def self.prepended(base)
        # spree try to create an empty order in the #new action
        base.around_action :set_writing_role, only: %i[new]

        base.before_action :load_order, only: %i[
          edit update cancel resume approve resend open_adjustments
          close_adjustments cart channel set_channel
          accept_all alert_request_to_vendor
        ]
      end

      def accept_all
        @order.accepted_by(try_spree_current_user)
        flash[:success] = Spree.t(:accepted)
        redirect_back fallback_location: spree.edit_admin_order_url(@order)
      end

      def alert_request_to_vendor
        @order.send_order_request_telegram_confirmation_alert_to_vendor

        flash[:success] = Spree.t(:alerted_to_vendor)
        redirect_back fallback_location: spree.edit_admin_order_url(@order)
      end

      # override
      def initialize_order_events
        @order_events = %w[alert_request_to_vendor approve cancel resume]
      end
    end
  end
end

unless Spree::Admin::OrdersController.ancestors.include?(SpreeCmCommissioner::Admin::OrdersControllerDecorator)
  Spree::Admin::OrdersController.prepend(SpreeCmCommissioner::Admin::OrdersControllerDecorator)
end
