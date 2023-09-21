module Spree
  module Admin
    class UserIdentityProvidersController < Spree::Admin::ResourceController
      belongs_to 'spree/user'

      def index
        @user_identity_providers = @user.user_identity_providers
      end

      # @overrided
      def model_class
        SpreeCmCommissioner::UserIdentityProvider
      end

      def object_name
        'spree_cm_commissioner_user_identity_provider'
      end

      # @overrided
      def collection_url(options = {})
        admin_user_user_identity_providers_url(options)
      end
    end
  end
end
