module SpreeCmCommissioner
  class TelegramStartMessageSender < BaseInteractor
    include Rails.application.routes.url_helpers

    delegate :chat_id, :telegram_bot, to: :context

    def call
      client = ::Telegram::Bot::Client.new(telegram_bot.token)
      client.send_photo(
        chat_id: chat_id,
        caption: telegram_bot.preferred_start_caption,
        photo: url_for(telegram_bot.start_photo),
        reply_markup: {
          inline_keyboard: [
            [{ text: telegram_bot.preferred_start_button_text, url: telegram_bot.preferred_start_button_url }]
          ]
        }.to_json
      )
    end
  end
end
