module SpreeCmCommissioner
  class TelegramChatsFinder < BaseInteractor
    delegate :telegram_chat_type, :telegram_chat_name, to: :context

    def call
      updates = fetch_updates
      context.chats = get_chats(updates)
    end

    def get_chats(updates)
      updates['result'].filter_map do |update|
        chat = update.dig('my_chat_member', 'chat')

        if chat.present? && chat['title'] == telegram_chat_name.strip && chat['type'] == telegram_chat_type
          return {
            id: chat['id'],
            title: chat['title'],
            type: chat['type']
          }
        end
      end
    end

    def fetch_updates
      ::Telegram.bot.get_updates
    end
  end
end
