module Spree
  module Billing
    class SubscriptionsController < Spree::Billing::BaseController
      before_action :load_subscription, if: -> { member_action? }
      before_action :load_variant, only: :create

      helper_method :customer

      def create
        @subscription = @variant.subscriptions.build(subscription_params.merge(variant_id: @variant.id))

        if @subscription.save
          flash[:success] = flash_message_for(@subscription, :successfully_created)
        else
          flash[:error] = flash_message_for(@subscription, :not_created)
        end

        redirect_to billing_customer_subscriptions_url(customer)
      end

      protected

      def collection
        return @collection if defined?(@collection)

        @search = customer.subscriptions.ransack(params[:q])
        @collection = @search.result.page(page).per(per_page)
      end

      def load_subscription
        @subscription = @object
      end

      def load_variant
        @variant = SpreeCmCommissioner::VariantChecker.new(variant_params, current_vendor).find_or_create_variant
      end

      def customer
        @customer ||= SpreeCmCommissioner::Customer.find(params[:customer_id])
      end

      # @overrided
      def model_class
        SpreeCmCommissioner::Subscription
      end

      # @overrided
      def object_name
        'spree_cm_commissioner_subscription'
      end

      # @overrided
      def collection_url(options = {})
        billing_customer_subscriptions_url(options)
      end

      def variant_params
        params.require(:variant).permit(:product_id, :sku, :price, option_value_ids: [])
      end

      def subscription_params
        params.require(:spree_cm_commissioner_subscription).permit(:start_date, :customer_id, :status, :variant_id)
      end
    end
  end
end
