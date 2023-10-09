module SpreeCmCommissioner
  class TelegramNotifier
    attr_reader :token, :channel_id, :telegram_client, :base_options

    def initialize(options)
      @base_options = options
      @token = options.delete(:token)
      @channel_id = options.delete(:channel_id)
      @telegram_client = ::Telegram.bots[:exception_notifier]
    end

    def call(exception, opts = {})
      options = base_options.merge(opts)
      formatter = ::ExceptionNotifier::Formatter.new(exception, options)
      data = options[:env]['exception_notifier.exception_data']

      telegram_client.send_message(
        chat_id: channel_id,
        parse_mode: 'HTML',
        text: body(exception, formatter, data)
      )
    rescue ::Telegram::Bot::Error => e
      # when telegram bot error, we try to send again without parse (raw text),
      # so we still can get exceptions and know what cause telegram error.
      telegram_client.send_message(
        chat_id: channel_id,
        text: body(exception, formatter, data, e)
      )
    end

    def body(exception, formatter, data, telegram_exception)
      text = []

      text << "<b>Application #{formatter.app_name}</b>"
      text << "\n"

      text << formatter.title
      text << formatter.subtitle
      text << "\n"

      text << '<b>Exception:</b>'
      text << exception.message
      text << "\n"

      if data.present?
        text << '<b>Set by controller:</b>'
        text << "<code>#{data}</code>"
        text << "\n"
      end

      if formatter.request_message.present? && formatter.request_message != "```\n```"
        text << '<b>Request:</b>'
        text << "<code>#{formatter.request_message}</code>"
        text << "\n"
      end

      if formatter.backtrace_message.present? && formatter.backtrace_message != "```\n```"
        text << '<b>Backtrace:</b>'
        text << "<code>#{formatter.backtrace_message}</code>"
        text << "\n"
      end

      text << telegram_exception.to_s if telegram_exception.present?

      text.compact.join("\n")
    end
  end
end
