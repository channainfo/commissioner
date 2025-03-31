module Blazer
  module BaseControllerDecorator
    def self.prepended(base)
      base.before_action :restrict_organizer_access
    end

    private

    def restrict_organizer_access
      return unless spree_current_user.organizer? && !spree_current_user.admin?
      return if controller_name == 'queries' && %w[show run].include?(action_name)

      raise ActionController::RoutingError, 'Unauthorized'
    end
  end
end

Blazer::BaseController.prepend(Blazer::BaseControllerDecorator) if defined?(Blazer::BaseController)
