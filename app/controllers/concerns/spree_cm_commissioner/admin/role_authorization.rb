module SpreeCmCommissioner
  module Admin
    module RoleAuthorization
      extend ActiveSupport::Concern

      included do
        before_action :authorize_role!

        rescue_from SpreeCmCommissioner::UnauthorizationError, with: :handle_unauthorization
      end

      def authorize_role!
        raise SpreeCmCommissioner::UnauthorizationError unless authorize?
      end

      def authorize?
        auth_user.admin? || auth_user.permissions.exists?(entry: auth_entry, action: auth_action)
      end

      def auth_user
        try_spree_current_user
      end

      def auth_entry
        controller_name
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
