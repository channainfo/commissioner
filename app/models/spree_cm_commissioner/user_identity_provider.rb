module SpreeCmCommissioner
  class UserIdentityProvider < Base
    enum identity_type: { :google => 0, :apple => 1, :facebook => 2, :telegram => 3 }

    belongs_to :user, class_name: Spree.user_class.to_s, optional: false

    validates :sub, presence: true
    validates :sub, uniqueness: { scope: :identity_type }

    validates :identity_type, presence: true
    validates :identity_type, uniqueness: { scope: :user_id }

    # sub is a telegram uid, which telegram considered a chatID if
    # user have /started with bot.
    def telegram_chat_id
      return sub if telegram?

      nil
    end
  end
end
