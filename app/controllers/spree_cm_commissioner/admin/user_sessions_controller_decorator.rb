module SpreeCmCommissioner
  module Admin
    module UserSessionsControllerDecorator
      def self.prepended(base)
        # spree_devise_auth gem use get as destroy
        # get '/logout' => 'user_sessions#destroy', :as => :logout
        base.around_action :set_writing_role, only: %i[destroy]
      end
    end
  end
end

unless Spree::Admin::UserSessionsController.ancestors.include?(SpreeCmCommissioner::Admin::UserSessionsControllerDecorator)
  Spree::Admin::UserSessionsController.prepend(SpreeCmCommissioner::Admin::UserSessionsControllerDecorator)
end
