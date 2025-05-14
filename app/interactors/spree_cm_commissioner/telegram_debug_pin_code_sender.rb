module SpreeCmCommissioner
  class TelegramDebugPinCodeSender < BaseInteractor
    delegate :pin_code, :name, :error_message, to: :context

    def call
      telegram_client.send_message(
        chat_id: chat_id,
        parse_mode: 'HTML',
        text: body
      )
    end

    def body
      text = []

      text << "<b>From: #{name}</b>"
      text << "<b>PIN CODE sent to #{pin_code.contact}</b>"
      text << "<code>#{pin_code.code}</code> is your #{pin_code.readable_type}"
      text << "⚠️ Error: <code>#{error_message}<code> ⚠️" if error_message.present?

      text.compact.join("\n")
    end

    def chat_id
      ENV.fetch('EXCEPTION_NOTIFIER_TELEGRAM_CHANNEL_ID', nil)
    end

    def telegram_client
      ::Telegram.bots[:exception_notifier]
    end
  end
end
