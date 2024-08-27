module Spree
  module Admin
    class TelegramBotsController < Spree::Admin::ResourceController
      helper_method :obfuscate_token

      def obfuscate_token(token)
        return nil if token.blank?
        return nil if token.length <= 10

        "#{token[0, 5]}#{'*' * (token.length - 10)}#{token[-5, 5]}"
      end

      def set_webhook
        telegram_bot = SpreeCmCommissioner::TelegramBot.find(params[:id])

        client = ::Telegram::Bot::Client.new(telegram_bot.token)

        response = client.set_webhook(
          url: "#{request.base_url}/api/webhook/telegram_bots",
          secret_token: telegram_bot.secure_token
        )

        if response['ok']
          flash[:success] = 'Webhook is set successfully.' # rubocop:disable Rails/I18nLocaleTexts
        else
          flash[:error] = 'Failed to set webhook.' # rubocop:disable Rails/I18nLocaleTexts
        end

        redirect_back fallback_location: collection_url
      end

      # override
      def model_class
        SpreeCmCommissioner::TelegramBot
      end

      # override
      def object_name
        'spree_cm_commissioner_telegram_bot'
      end

      # override
      def collection_url(options = {})
        admin_telegram_bots_url(options)
      end
    end
  end
end
