module SpreeCmCommissioner
  module UserDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::PhoneNumberSanitizer

      base.enum gender: %i[male female other]
      base.has_many :user_identity_providers, dependent: :destroy, class_name: 'SpreeCmCommissioner::UserIdentityProvider'
      base.has_many :customers, class_name: 'SpreeCmCommissioner::Customer'
      base.has_many :subscriptions, through: :customers, class_name: 'SpreeCmCommissioner::Subscription'
      base.has_many :payments, as: :payable, class_name: 'Spree::Payment', dependent: :nullify
      base.has_many :role_permissions, through: :spree_roles, class_name: 'SpreeCmCommissioner::RolePermission'
      base.has_many :permissions, through: :role_permissions, class_name: 'SpreeCmCommissioner::Permission'
      base.has_many :device_tokens, class_name: 'SpreeCmCommissioner::DeviceToken'
      base.has_many :notifications, class_name: 'SpreeCmCommissioner::Notification', as: :recipient, dependent: :destroy

      base.has_one :profile, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::UserProfile'

      base.whitelisted_ransackable_attributes = %w[email first_name last_name gender phone_number]

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

      def full_name
        [first_name, last_name].reject(&:empty?).join(' ')
      end
    end

    def device_tokens?
      device_tokens.any?
    end

    def ensure_unique_database_delivery_method(attributes)
      recipient = self

      options = {
        recipient_id: recipient.id,
        notificable_id: attributes[:notificable].id,
        notificable_type: attributes[:notificable].class.to_s
      }

      notification = recipient.notifications.where(options).first_or_initialize

      return notification if notification.persisted?

      notification.assign_attributes(attributes)
      notification.save!

      notification
    end
  end
end

Spree::User.prepend(SpreeCmCommissioner::UserDecorator) unless Spree::User.included_modules.include?(SpreeCmCommissioner::UserDecorator)
