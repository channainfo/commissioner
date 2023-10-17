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

    def parse_mode
      'HTML'
    end

    def pretty_date(date)
      return '' if date.blank?

      [I18n.l(date.to_date, format: :long)].join(' ')
    end
  end
end
