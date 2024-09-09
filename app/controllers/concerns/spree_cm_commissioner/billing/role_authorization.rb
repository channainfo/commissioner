module SpreeCmCommissioner
  module Billing
    module RoleAuthorization
      extend ActiveSupport::Concern

      included do
        rescue_from SpreeCmCommissioner::UnauthorizationError, with: :redirect_unauthorized_access
      end

      def authorize_role!
        raise SpreeCmCommissioner::UnauthorizationError unless authorize?
      end

      # overrided
      def authorize_admin
        authorize_role!
      end

      def authorize?
        auth_user.present? && (auth_user.admin? || auth_user.permissions.exists?(entry: auth_entry, action: auth_action))
      end

      # override cancancan
      def authorize!(_action, _object)
        authorize?
      end

      def auth_user
        ActiveRecord::Base.connected_to(role: :writing) do
          try_spree_current_user
        end
      end

      def auth_entry
        controller_path
      end

      def auth_action
        action_name
      end

      def redirect_unauthorized_access
        store_location # store current location in session for redirect after login

        if auth_user.nil?
          redirect_to spree.admin_login_path
        else
          redirect_to billing_forbidden_url
        end
      end
    end
  end
end
