module SpreeCmCommissioner
  class UserTelegramWebAppAuthenticator < BaseInteractor
    delegate :telegram_init_data, :telegram_bot_username, to: :context

    def call
      return context.fail!(message: 'telegram_bot_username_is_not_valid_or_not_exist_in_db') if telegram_bot.blank?
      return context.fail!(message: 'invalid_init_data') if checker.blank?

      context.telegram_user = ActiveSupport::JSON.decode(checker.checker_context.decoded_telegram_init_data['user'])
      context.user = find_or_create_telegram_user
    end

    def find_or_create_telegram_user
      identity = SpreeCmCommissioner::UserIdentityProvider.telegram.find_or_initialize_by(sub: context.telegram_user['id'])

      provider_telegram_bot = identity.user_identity_provider_telegram_bots.where(telegram_bot_id: telegram_bot.id).first_or_initialize
      provider_telegram_bot.last_sign_in_at = Time.zone.now

      if identity.new_record?
        user = Spree::User.new do |u|
          identity.name = context.telegram_user['username']
          u.first_name = context.telegram_user['first_name']
          u.last_name = context.telegram_user['last_name']
          u.password = SecureRandom.base64(16)
          u.user_identity_providers = [identity]
        end

        user.save!
        user
      else
        provider_telegram_bot.save!
        identity.user
      end
    end

    def checker
      result = TelegramWebAppInitDataValidator.call(telegram_init_data: telegram_init_data, bot_token: telegram_bot.token)
      context.checker ||= checker_struct.new(result, telegram_bot) if result.success?
    end

    def telegram_bot
      context.telegram_bot ||= TelegramBot.find_by(username: telegram_bot_username)
    end

    def checker_struct
      Struct.new(:checker_context, :telegram_bot)
    end
  end
end
