module Spree
  module Api
    module Webhook
      class TelegramBotsController < BaseController
        before_action :load_telegram_bot
        skip_before_action :load_subsriber

        def create
          chat_id = params.dig(:message, :chat, :id)
          text = params.dig(:message, :text)

          if text == '/start' && chat_id.present?
            send_message_to_user_in_queue(chat_id)
            head :ok
          else
            head :unprocessable_entity
          end
        end

        def send_message_to_user_in_queue(chat_id)
          SpreeCmCommissioner::TelegramStartMessageSenderJob.perform_later(
            chat_id: chat_id,
            telegram_bot_id: @telegram_bot.id
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
