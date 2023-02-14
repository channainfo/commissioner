module SpreeCmCommissioner
  module UserDecorator
    def self.prepended(base)
      base.enum gender: %i[male female other]
      base.has_many :user_identity_providers, dependent: :destroy, class_name: 'SpreeCmCommissioner::UserIdentityProvider'
      base.has_one :profile, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::UserProfile'

      base.whitelisted_ransackable_attributes = %w[email first_name last_name gender]
    end
  end
end

unless Spree::User.included_modules.include?(SpreeCmCommissioner::UserDecorator)
  Spree::User.prepend(SpreeCmCommissioner::UserDecorator)
end
