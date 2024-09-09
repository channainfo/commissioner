module Spree
  module Admin
    class DeviceTokensController < Spree::Admin::ResourceController
      belongs_to 'spree/user'

      def index
        @device_tokens = @user.device_tokens
      end

      # @overrided
      def model_class
        SpreeCmCommissioner::DeviceToken
      end

      def object_name
        'spree_cm_commissioner_device_token'
      end

      # @overrided
      def collection_url(options = {})
        admin_user_device_tokens_url(options)
      end
    end
  end
end
