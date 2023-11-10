module Spree
  module Admin
    class WebhooksSubscriberOrdersController < Spree::Admin::ResourceController
      before_action :load_webhooks_subscriber
      before_action :load_orders

      def load_webhooks_subscriber
        @webhooks_subscriber = Spree::Webhooks::Subscriber.find(params[:webhooks_subscriber_id])
      end

      # @overrided
      def load_orders
        @orders = Spree::Order.all
        @webhooks_subscriber.rules.each do |rule|
          @orders = rule.filter(@orders)
        end
      end

      def index; end
      def show; end

      def queue
        if params[:state].present?
          SpreeCmCommissioner::WebhookSubscriberOrdersSenderJob.perform_later(
            order_state: params[:state],
            webhooks_subscriber_id: @webhooks_subscriber.id
          )
          flash[:success] = Spree.t(:sent)
        else
          flash[:error] = Spree.t(:send_failed_or_method_not_support)
        end
      end

      # @overrided
      def model_class
        Spree::Order
      end

      def collection_url(options = {})
        admin_webhooks_subscriber_orders_path(options)
      end
    end
  end
end
