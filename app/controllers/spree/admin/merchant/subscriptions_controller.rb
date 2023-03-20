module Spree
  module Admin
    module Merchant
      class SubscriptionsController < Spree::Admin::Merchant::BaseController
        before_action :load_user

        def index
          @search = @user.user_subscriptions.ransack(params[:q])
          @subscriptions = @search.result.page(page).per(per_page)
        end

        # @overrided
        def model_class
          SpreeCmCommissioner::UserSubscription
        end

        def object_name
          'spree_cm_commissioner_user_subscription'
        end

        def collection_url(options = {})
          admin_merchant_user_subscriptions_url(options)
        end

        def load_user
          @user = Spree::User.find_by(id: params[:user_id])
        end
      end
    end
  end
end
