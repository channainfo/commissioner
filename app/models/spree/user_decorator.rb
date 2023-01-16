module Spree
  module UserDecorator
    def self.prepended(base)
      base.enum gender: %i[male female other]
      base.has_many :user_identity_providers, dependent: :destroy, class_name: 'SpreeCmCommissioner::UserIdentityProvider'
      base.whitelisted_ransackable_attributes = %w[email first_name last_name gender]
    end
  end
end

Spree::User.prepend(Spree::UserDecorator) if Spree::User.included_modules.exclude?(Spree::UserDecorator)
