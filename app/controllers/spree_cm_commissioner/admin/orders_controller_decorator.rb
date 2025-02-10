module SpreeCmCommissioner
  module Admin
    module OrdersControllerDecorator
      def self.prepended(base)
        # spree try to create an empty order in the #new action
        base.around_action :set_writing_role, only: %i[new edit]

        base.before_action :load_order, only: %i[
          edit update cancel resume approve resend open_adjustments
          close_adjustments cart channel set_channel
          accept_all reject_all alert_request_to_vendor
          notifications fire_notification queue_webhooks_requests update_order_status
        ]

        base.before_action :initialize_notification_methods, only: %i[
          notifications
          fire_notification
          queue_webhooks_requests
        ]
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

      def queue_webhooks_requests
        event = @webhook_events.find { |e| e == params['event'] }

        if event.present?
          Spree::Webhooks::Subscribers::QueueRequests.call(
            event_name: event,
            webhook_payload_body: @order.send(:webhook_payload_body),
            **@order.send(:webhooks_request_options)
          )
          flash[:success] = Spree.t(:sent)
        else
          flash[:error] = Spree.t(:send_failed_or_method_not_support)
        end

        redirect_back fallback_location: notifications_admin_order_url(@order)
      end

      def notifications; end

      def update_order_status
        if @order.next
          flash[:success] = I18n.t('orders.update_order_status.success')
        else
          error_message = @order.errors.full_messages.to_sentence
          flash[:error] = (error_message.presence || I18n.t('orders.update_order_status.fail'))
        end
        redirect_back fallback_location: spree.edit_admin_order_url(@order)
      end

      # override
      def resume
        resumed = @order.resume
        if resumed
          flash[:success] = 'Order resumed' # rubocop:disable Rails/I18nLocaleTexts
        else
          flash[:error] = @order.errors.full_messages.to_sentence
        end
        redirect_back fallback_location: spree.edit_admin_order_url(@order)
      end

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

          notify_order_complete_app_notification_to_user
          notify_order_complete_telegram_notification_to_user
        ]

        @webhook_events = [
          'order.create',
          'order.delete',
          'order.update',
          'order.canceled',
          'order.placed',
          'order.resumed',
          'order.shipped'
        ]
      end
    end
  end
end

unless Spree::Admin::OrdersController.ancestors.include?(SpreeCmCommissioner::Admin::OrdersControllerDecorator)
  Spree::Admin::OrdersController.prepend(SpreeCmCommissioner::Admin::OrdersControllerDecorator)
end
