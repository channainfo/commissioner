module SpreeCmCommissioner
  module Admin
    module OrdersControllerDecorator
      def self.prepended(base)
        # spree try to create an empty order in the #new action
        base.around_action :set_writing_role, only: %i[new]

        base.before_action :load_order, only: %i[
          edit update cancel resume approve resend open_adjustments
          close_adjustments cart channel set_channel
          accept_all reject_all alert_request_to_vendor
          notifications fire_notification
        ]

        base.before_action :initialize_notification_methods, only: %i[notifications fire_notification]
      end

      def accept_all
        @order.accepted_by(try_spree_current_user)
        flash[:success] = Spree.t(:accepted)
        redirect_back fallback_location: spree.edit_admin_order_url(@order)
      end

      def reject_all
        @order.rejected_by(try_spree_current_user)
        flash[:success] = Spree.t(:rejected)
        redirect_back fallback_location: spree.edit_admin_order_url(@order)
      end

      def alert_request_to_vendor
        @order.send_order_request_telegram_confirmation_alert_to_vendor

        flash[:success] = Spree.t(:alerted_to_vendor)
        redirect_back fallback_location: spree.edit_admin_order_url(@order)
      end

      def fire_notification
        method = @notification_methods.find { |e| e == params['notification_method'] }

        if method.present? && @order.send(method)
          flash[:success] = Spree.t(:sent)
        else
          flash[:error] = Spree.t(:send_failed_or_method_not_support)
        end

        redirect_back fallback_location: notifications_admin_order_url(@order)
      end

      def notifications; end

      # override
      def initialize_order_events
        @order_events = %w[alert_request_to_vendor approve cancel resume]
      end

      def initialize_notification_methods
        @notification_methods = %w[
          send_order_complete_telegram_alert_to_vendors
          send_order_complete_telegram_alert_to_store

          send_order_requested_telegram_alert_to_store
          send_order_accepted_telegram_alert_to_store
          send_order_rejected_telegram_alert_to_store
        ]
      end
    end
  end
end

unless Spree::Admin::OrdersController.ancestors.include?(SpreeCmCommissioner::Admin::OrdersControllerDecorator)
  Spree::Admin::OrdersController.prepend(SpreeCmCommissioner::Admin::OrdersControllerDecorator)
end
