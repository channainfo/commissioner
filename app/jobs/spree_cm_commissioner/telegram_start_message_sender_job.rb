module SpreeCmCommissioner
  class TelegramStartMessageSenderJob < ApplicationJob
    queue_as :telegram_bot

    # :chat_id, :telegram_bot_id
    def perform(options)
      telegram_bot = SpreeCmCommissioner::TelegramBot.find(options[:telegram_bot_id])
      TelegramStartMessageSender.call(
        chat_id: options[:chat_id],
        telegram_bot: telegram_bot
      )
    end
  end
end
