# https://stackoverflow.com/questions/77318060/blazer-raised-activerecordconnectionnotestablished
module Blazer
  module BaseControllerDecorator
    def self.prepended(base)
      base.around_action :set_writing_role
      base.before_action :restrict_organizer_access
    end

    # Annonymous block: https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Naming/BlockForwarding
    def set_writing_role(&block)
      ActiveRecord::Base.connected_to(role: :writing, &block)
    end

    def restrict_organizer_access
      return unless spree_current_user.organizer? && !spree_current_user.admin?
      return if controller_name == 'queries' && %w[show run].include?(action_name)

      raise ActionController::RoutingError, 'Unauthorized'
    end
  end
end

Blazer::BaseController.prepend(Blazer::BaseControllerDecorator) unless Blazer::BaseController.ancestors.include?(Blazer::BaseControllerDecorator)
