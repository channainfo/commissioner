module Spree
  module Telegram
    class ErrorsController < BaseController
      skip_before_action :required_telegram_vendor_user!

      def forbidden
        @message = "You're either not a vendor user or the vendor isn't belonging to you."
      end

      def resource_not_found
        @message = 'Resources you are looking are not found.'
      end
    end
  end
end
