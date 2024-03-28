module Spree
  module Events
    class ErrorsController < Spree::Admin::BaseController
      layout 'spree/layouts/error_template'

      before_action :authorize_admin

      def forbidden
        @error = 'Forbidden Access'
        @message = "You're either not a organizer or the event isn't belonging to you."
      end
    end
  end
end
