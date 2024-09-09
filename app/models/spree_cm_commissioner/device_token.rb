module SpreeCmCommissioner
  class DeviceToken < SpreeCmCommissioner::Base
    belongs_to :user, class_name: 'Spree::User'
    after_commit :update_user_device_token_count

    validates :registration_token, uniqueness: { scope: %i[user_id client_name] }
    validates :registration_token, presence: true

    def update_user_device_token_count
      user.update(device_tokens_count: user.device_tokens.count)
    end
  end
end
