module SpreeCmCommissioner
  class TelegramMessageFactory
    attr_reader :title, :subtitle

    def initialize(title:, subtitle: nil)
      @title = title
      @subtitle = subtitle
    end

    def message
      text = []

      text << header.presence
      text << subtitle.presence if subtitle.present?
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
