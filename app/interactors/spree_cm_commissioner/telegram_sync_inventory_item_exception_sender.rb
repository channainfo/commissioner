module SpreeCmCommissioner
  class TelegramSyncInventoryItemExceptionSender < BaseInteractor
    delegate :inventory_id_and_quantities, :line_item_ids, :exception, to: :context

    def call
      telegram_client.send_message(
        chat_id: chat_id,
        parse_mode: 'HTML',
        text: body
      )
    end

    private

    def body
      backtrace = backtrace_message(exception)
      text = []
      text << '<b>InventoryItemSyncer Fails!</b>'
      text << "Params: <b>line_item_ids</b>: <pre>#{JSON.pretty_generate(line_item_ids)}</pre>"
      text << "Params: <b>inventory_id_and_quantities</b>: <pre>#{JSON.pretty_generate(inventory_id_and_quantities)}</pre>"
      text << "Error: <b>message</b>: <pre>#{exception.message}</pre>"
      text << "Error: <b>backtrace</b>: <pre>#{backtrace}</pre>" if backtrace.present?
      text.compact.join("\n")
    end

    def backtrace_message(exception)
      backtrace = exception.backtrace
      return if backtrace.blank?

      text = []

      text << '```'
      backtrace.first(5).each { |line| text << "* #{line}" }
      text << '```'

      text.join("\n")
    end

    def chat_id
      ENV.fetch('EXCEPTION_NOTIFIER_TELEGRAM_CHANNEL_ID', nil)
    end

    def telegram_client
      ::Telegram.bots[:exception_notifier]
    end
  end
end
