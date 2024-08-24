module Spree
  module Admin
    class TelegramBotsController < Spree::Admin::ResourceController
      helper_method :obfuscate_token

      def obfuscate_token(token)
        return nil if token.blank?
        return nil if token.length <= 10

        "#{token[0, 5]}#{'*' * (token.length - 10)}#{token[-5, 5]}"
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
