module SpreeCmCommissioner
  module Billing
    module RoleAuthorization
      extend ActiveSupport::Concern

      included do
        rescue_from SpreeCmCommissioner::UnauthorizationError, with: :handle_unauthorization
      end

      def authorize_role!
        raise SpreeCmCommissioner::UnauthorizationError unless authorize?
      end

      # overrided
      def authorize_admin
        authorize_role!
      end

      def authorize?
        auth_user.admin? || auth_user.permissions.exists?(entry: auth_entry, action: auth_action)
      end

      def auth_user
        try_spree_current_user
      end

      def auth_entry
        controller_path
      end

      def auth_action
        action_name
      end

      def handle_unauthorization
        redirect_to billing_forbidden_url
      end
    end
  end
end
