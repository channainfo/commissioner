module Spree
  module UserDecorator
    def self.prepended(base)
      base.enum gender: %i[male female other]
      base.has_many :user_identity_providers, dependent: :destroy, class_name: 'SpreeCmCommissioner::UserIdentityProvider'
<<<<<<< HEAD
      base.whitelisted_ransackable_attributes = %w[email first_name last_name gender]
=======

      base.whitelisted_ransackable_attributes = %w[email first_name last_name gender]
      base.has_one :profile, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::UserProfile'
>>>>>>> 21e7e3a (close #99-user-profile)
    end
  end
end

Spree::User.prepend(Spree::UserDecorator) if Spree::User.included_modules.exclude?(Spree::UserDecorator)
