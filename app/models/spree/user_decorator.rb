module Spree
  module UserDecorator
    def self.prepended(base)
      base.has_many :user_identity_providers, dependent: :destroy, class_name: 'SpreeCmCommissioner::UserIdentityProvider'
    end
  end
end

Spree::User.prepend(Spree::UserDecorator)