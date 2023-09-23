module SpreeCmCommissioner
  module Admin
    module UserSessionsControllerDecorator
      def self.prepended(base)
        # spree_devise_auth
        # get '/logout' => #destroy uses destroy
        # get '/login' => #ne  updates signe_in_count
        base.around_action :set_writing_role, only: %i[destroy new]
      end
    end
  end
end

unless Spree::Admin::UserSessionsController.ancestors.include?(SpreeCmCommissioner::Admin::UserSessionsControllerDecorator)
  Spree::Admin::UserSessionsController.prepend(SpreeCmCommissioner::Admin::UserSessionsControllerDecorator)
end
