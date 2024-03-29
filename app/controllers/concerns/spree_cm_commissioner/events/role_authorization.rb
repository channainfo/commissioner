module SpreeCmCommissioner
  module Events
    module RoleAuthorization
      extend ActiveSupport::Concern

      included do
        rescue_from SpreeCmCommissioner::UnauthorizedEventError, with: :redirect_unauthorized_access
        rescue_from ActiveRecord::RecordNotFound, with: :resource_not_found
      end

      def authorize_role!
        raise SpreeCmCommissioner::UnauthorizedEventError unless authorize?
      end

      # overrided
      def authorize_admin
        authorize_role!
      end

      def authorize?
        return false if spree_current_user.blank?

        spree_current_user.organizer?
      end

      def resource_not_found
        redirect_to resource_not_found_events_path
      end

      # overrided
      def redirect_unauthorized_access
        redirect_to forbidden_events_path
      end
    end
  end
end
