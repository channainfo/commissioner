module SpreeCmCommissioner
  class TelegramBotMessageSenderJob < ApplicationJob
    queue_as :default

    def perform; end
  end
end
