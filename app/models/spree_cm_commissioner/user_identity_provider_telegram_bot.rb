module SpreeCmCommissioner
  class UserIdentityProviderTelegramBot < Base
    belongs_to :user_identity_provider, optional: false
    belongs_to :telegram_bot, optional: false

    def self.last_sign_in
      order(last_sign_in_at: :desc).first
    end
  end
end
