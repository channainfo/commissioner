module SpreeCmCommissioner
  module UserDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::PhoneNumberSanitizer

      base.enum gender: %i[male female other]
      base.has_many :user_identity_providers, dependent: :destroy, class_name: 'SpreeCmCommissioner::UserIdentityProvider'
      base.has_many :user_subscriptions, class_name: 'SpreeCmCommissioner::UserSubscription'

      base.has_one :profile, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::UserProfile'
      base.belongs_to :taxon

      base.whitelisted_ransackable_attributes = %w[email first_name last_name gender]

      def base.find_user_by_login(login)
        login = login.downcase
        parser = PhoneNumberParser.call(phone_number: login)

        if parser.intel_phone_number.present?
          where(intel_phone_number: parser.intel_phone_number)
        elsif login =~ URI::MailTo::EMAIL_REGEXP
          where(email: login)
        else
          where(login: login)
        end
      end
    end
  end
end

Spree::User.prepend(SpreeCmCommissioner::UserDecorator) unless Spree::User.included_modules.include?(SpreeCmCommissioner::UserDecorator)
