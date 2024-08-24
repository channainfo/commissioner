module SpreeCmCommissioner
  class TelegramBot < Base
    # eg. bookmeplus_bot, no start with @
    validates :username, presence: true
    validates :token, presence: true

    has_many :user_identity_provider_telegram_bots
    has_many :user_identity_providers, through: :user_identity_provider_telegram_bots
  end
end
