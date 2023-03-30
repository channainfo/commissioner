module Spree
  module Admin
    module Merchant
      class RoleAuthorization
        included do
          before_action :authorize_role!
        end

        def authorize_role!
          raise AuthorizationError if !auth_role
        end

        def auth_role
          SpreeCmCommissioner::Role.new(auth_user, auth_entry, auth_action).authorize?
        end

        def auth_user
          nil
        end

        def auth_entry
          controller_name
        end

        def auth_action
          action_name
        end
      end
    end
  end
end