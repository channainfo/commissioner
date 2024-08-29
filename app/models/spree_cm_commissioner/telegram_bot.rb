module SpreeCmCommissioner
  class TelegramBot < Base
    # eg. bookmeplus_bot, no start with @
    validates :username, :token, :start_photo, presence: true
    validates :preferred_start_button_text, :preferred_start_button_url, presence: true

    preference :start_caption, :text
    preference :start_button_text, :string
    preference :start_button_url, :string
    preference :start_parse_mode, :string

    has_one_attached :start_photo
    has_secure_token :secure_token, length: 32

    has_many :user_identity_provider_telegram_bots
    has_many :user_identity_providers, through: :user_identity_provider_telegram_bots
  end
end
