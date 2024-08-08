module SpreeCmCommissioner
  class UserTelegramWebAppAuthenticator < BaseInteractor
    delegate :telegram_init_data, to: :context

    def call
      return context.fail!(message: 'invalid_init_data') unless checker_context.success?

      context.telegram_user = ActiveSupport::JSON.decode(checker_context.decoded_telegram_init_data['user'])
      context.user = find_or_create_telegram_user
    end

    def find_or_create_telegram_user
      identity = SpreeCmCommissioner::UserIdentityProvider.telegram.find_or_initialize_by(sub: context.telegram_user['id'])

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
        identity.user
      end
    end

    def checker_context
      context.checker_context ||= SpreeCmCommissioner::TelegramWebAppInitDataValidator.call(
        telegram_init_data: telegram_init_data,
        bot_token: telegram_bot_token
      )
    end

    def telegram_bot_token
      ENV.fetch('DEFAULT_TELEGRAM_BOT_API_TOKEN', nil)
    end
  end
end
