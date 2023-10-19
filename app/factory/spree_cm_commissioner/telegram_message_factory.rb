module SpreeCmCommissioner
  class TelegramMessageFactory
    attr_reader :title

    def initialize(title:)
      @title = title
    end

    def message
      text = []

      text << header.presence
      text << body.presence
      text << footer.presence

      text.compact.join("\n\n")
    end

    def header
      "<b>#{title}</b>"
    end

    def body; end
    def footer; end

    def bold(text)
      "<b>#{text}</b>"
    end

    def italic(text)
      "<i>#{text}</i>"
    end

    def inline_code(text)
      "<code>#{text}</code>"
    end

    def parse_mode
      'HTML'
    end

    def pretty_date(date)
      return '' if date.blank?

      date.to_date.strftime('%b %d, %Y')
    end
  end
end
