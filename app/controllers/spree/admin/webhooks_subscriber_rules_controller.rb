module Spree
  module Admin
    class WebhooksSubscriberRulesController < Spree::Admin::ResourceController
      before_action :load_webhooks_subscriber

      def load_webhooks_subscriber
        @webhooks_subscriber = Spree::Webhooks::Subscriber.find(params[:webhooks_subscriber_id])
      end

      def scope
        load_webhooks_subscriber

        @webhooks_subscriber.rules
      end

      # @overrided
      def collection
        scope
      end

      # @overrided
      def load_resource_instance
        return scope.new if new_actions.include?(action)

        scope.find(params[:id])
      end

      def collection_url(options = {})
        edit_admin_webhooks_subscriber_url(params[:webhooks_subscriber_id], options)
      end

      # @overrided
      def model_class
        SpreeCmCommissioner::Webhooks::SubscriberRule
      end

      # @overrided
      # depend on type of rule eg. spree_cm_commissioner_webhooks_rules_vendors
      def object_name
        @object.class.to_s.underscore.tr('/', '_')
      end
    end
  end
end
