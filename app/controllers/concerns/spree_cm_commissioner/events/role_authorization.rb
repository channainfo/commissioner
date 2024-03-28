module SpreeCmCommissioner
  module Events
    module RoleAuthorization
      extend ActiveSupport::Concern

      def authorize_role!
        raise SpreeCmCommissioner::UnauthorizationError unless authorize?
      end

      # overrided
      def authorize_admin
        authorize_role!
      end

      def authorize?
        auth_user.present? && auth_user.organizer?
      end

      # override cancancan
      def authorize!(_action, _object)
        authorize?
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

      def redirect_unauthorized_access
        store_location # store current location in session for redirect after login

        if auth_user.nil?
          redirect_to spree.admin_login_path
        else
          redirect_to forbidden_events_path
        end
      end
    end
  end
end
