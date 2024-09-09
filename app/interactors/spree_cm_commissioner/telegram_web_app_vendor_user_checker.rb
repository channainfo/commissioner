module SpreeCmCommissioner
  class TelegramWebAppVendorUserChecker < BaseInteractor
    delegate :decoded_telegram_init_data, to: :context

    def call
      context.decoded_telegram_user_id = decode_telegram_user_id
      context.user = find_spree_user(context.decoded_telegram_user_id)

      check_vendors
    end

    def decode_telegram_user_id
      decode_telegram_user = ActiveSupport::JSON.decode(decoded_telegram_init_data['user'])
      telegram_user_id = decode_telegram_user['id']

      return telegram_user_id if telegram_user_id.present?

      context.fail!(message: 'Telegram user is not provided')
    end

    def find_spree_user(telegram_user_id)
      user_identity_provider = SpreeCmCommissioner::UserIdentityProvider.find_by(identity_type: :telegram, sub: telegram_user_id)

      return user_identity_provider.user if user_identity_provider&.user.present?

      context.fail!(message: 'Could not find connected user')
    end

    def check_vendors
      return unless context.user.vendors.empty?

      context.fail!(message: "You're not a vendor user")
    end
  end
end
