module Spree
  module Events
    class ErrorsController < Spree::Admin::BaseController
      layout 'spree/layouts/error_template'

      # override
      def authorize_admin; end

      def forbidden
        @error = 'Forbidden Access'
        @message = "You're either not a organizer or the event isn't belonging to you."
      end

      def resource_not_found
        @message = 'Resources you are looking are not found.'
      end
    end
  end
end
