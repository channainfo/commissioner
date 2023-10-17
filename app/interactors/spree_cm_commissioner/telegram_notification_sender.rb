module SpreeCmCommissioner
  class TelegramNotificationSender < BaseInteractor
    delegate :chat_id, :message, :parse_mode, to: :context

    def call
      telegram_client.send_message(
        chat_id: chat_id,
        parse_mode: parse_mode,
        text: message
      )
    rescue ::Telegram::Bot::Error => e
      notifier_error_message(e.to_s)
    end

    def telegram_client
      context.telegram_client ||= ::Telegram.bots[:default]
    end

    def notifier_error_message(error_message)
      ::Telegram.bots[:exception_notifier].send_message(
        chat_id: chat_id,
        text: "Telgram Notifier Error:\n#{error_message}\nSend Text:\n#{message}"
      )
    end
  end
end
