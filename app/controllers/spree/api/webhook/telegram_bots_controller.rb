module Spree
  module Api
    module Webhook
      class TelegramBotsController < BaseController
        include Rails.application.routes.url_helpers

        before_action :load_telegram_bot
        skip_before_action :load_subsriber

        def create
          chat_id = params[:message][:chat][:id]

          client = ::Telegram::Bot::Client.new(@telegram_bot.token)

          client.send_photo(
            chat_id: chat_id,
            caption: @telegram_bot.preferred_start_caption,
            photo: url_for(@telegram_bot.start_photo),
            reply_markup: {
              inline_keyboard: [
                [{ text: @telegram_bot.preferred_start_button_text, url: @telegram_bot.preferred_start_button_url }]
              ]
            }.to_json
          )
        end

        private

        def load_telegram_bot
          secure_token = request.headers['X-Telegram-Bot-Api-Secret-Token']
          @telegram_bot = SpreeCmCommissioner::TelegramBot.find_by(secure_token: secure_token)
          raise CanCan::AccessDenied if @telegram_bot.blank?
        end
      end
    end
  end
end
