module SpreeCmCommissioner
  class TelegramNotificationSenderJob < ApplicationJob
    def perform(options)
      return if options[:chat_id].nil?

      SpreeCmCommissioner::TelegramNotificationSender.call(
        chat_id: options[:chat_id],
        message: options[:message],
        parse_mode: options[:parse_mode]
      )
    end
  end
end
