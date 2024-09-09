module SpreeCmCommissioner
  class OrderCompleteTelegramSender < BaseInteractor
    delegate :order, to: :context

    def call
      context.user = Spree::User.find_by(id: order.user_id)
      return context.fail!(message: 'User must be present') if context.user.blank?
      return context.fail!(message: 'User is not connected to Telegram') if context.user.user_identity_providers.empty?

      # current implmenetation of identity providers is only allow user to connect 1 Telegram account.
      # but we loop here just in case those logics are changed.
      context.user.user_identity_providers.telegram.each do |provider|
        next unless provider.telegram_bots.any?

        telegram_bot = get_last_sign_in_bot(provider)
        send(telegram_bot.token, provider.telegram_chat_id)
      end
    end

    def send(telegram_bot_token, chat_id)
      telegram_client = ::Telegram::Bot::Client.new(telegram_bot_token)
      telegram_client.send_message(
        chat_id: chat_id,
        parse_mode: message_factory.parse_mode,
        text: message_factory.message
      )
    end

    def message_factory
      context.message_factory ||= OrderTelegramMessageFactory.new(
        title: 'Order Summary',
        show_details_link: true,
        order: order
      )
    end

    def get_last_sign_in_bot(user_identity_provider)
      user_identity_provider.user_identity_provider_telegram_bots.last_sign_in.telegram_bot
    end
  end
end
