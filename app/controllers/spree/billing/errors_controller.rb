module Spree
  module Billing
    class ErrorsController < Spree::Admin::BaseController
      layout 'spree/layouts/error_template'

      def forbidden
        @error = 'Forbidden Access'
        @message = "You're either not a vendor user or the vendor isn't belonging to you."
      end
    end
  end
end
