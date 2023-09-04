module Spree
  module Telegram
    class BaseController < ApplicationController
      layout 'spree_cm_commissioner/layouts/telegram'
      helper 'spree_cm_commissioner/telegram/base'

      before_action :required_telegram_vendor_user!

      rescue_from SpreeCmCommissioner::UnauthorizedVendorError, with: :handle_unauthorized_vendor
      rescue_from ActiveRecord::RecordNotFound, with: :resource_not_found

      def required_telegram_vendor_user!
        raise SpreeCmCommissioner::UnauthorizedVendorError if params[:telegram_init_data].blank?
        raise SpreeCmCommissioner::UnauthorizedVendorError unless authorizer_context.success?
      end

      def resource_not_found
        redirect_to telegram_resource_not_found_url
      end

      def handle_unauthorized_vendor
        redirect_to telegram_forbidden_url
      end

      def authorized_vendors
        @authorized_vendors ||= authorizer_context.user.vendors
      end

      def authorizer_context
        @authorizer_context ||= ::SpreeCmCommissioner::TelegramWebAppVendorUserAuthorizer.call(
          telegram_init_data: params[:telegram_init_data],
          bot_token: ENV.fetch('DEFAULT_TELEGRAM_BOT_API_TOKEN', nil)
        )
      end
    end
  end
end
