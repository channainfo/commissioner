# rubocop:disable Metrics/MethodLength
module SpreeCmCommissioner
  module UserDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::PhoneNumberSanitizer
      base.include SpreeCmCommissioner::UserNotification

      base.enum gender: %i[male female other]

      base.validates :email, presence: true, if: :email_required?
      base.validates :phone_number, uniqueness: { allow_blank: true }

      base.has_many :user_identity_providers, dependent: :destroy, class_name: 'SpreeCmCommissioner::UserIdentityProvider'
      base.has_many :customers, class_name: 'SpreeCmCommissioner::Customer'
      base.has_many :subscriptions, through: :customers, class_name: 'SpreeCmCommissioner::Subscription'
      base.has_many :payments, as: :payable, class_name: 'Spree::Payment', dependent: :nullify
      base.has_many :role_permissions, through: :spree_roles, class_name: 'SpreeCmCommissioner::RolePermission'
      base.has_many :permissions, through: :role_permissions, class_name: 'SpreeCmCommissioner::Permission'
      base.has_many :line_items, through: :orders, source: :line_items

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

      def base.end_users
        joins('LEFT JOIN spree_vendor_users ON spree_users.id = spree_vendor_users.user_id').where(spree_vendor_users: { user_id: nil })
      end

      def normal_user?
        system_user = admin? || !vendors.empty?
        normal_user = spree_roles.length == 1 ? spree_roles[0].name == 'user' : spree_roles.empty?
        normal_user && !system_user
      end
    end

    def full_name
      [first_name, last_name].reject(&:empty?).join(' ')
    end

    def ensure_unique_database_delivery_method(attributes)
      recipient = self

      options = {
        recipient_id: recipient.id,
        notificable_id: attributes[:notificable].id,
        notificable_type: attributes[:notificable].class.to_s,
        type: attributes[:type]
      }

      notification = recipient.notifications.where(options).first_or_initialize

      return notification if notification.persisted?

      notification.assign_attributes(attributes)
      notification.save!

      notification
    end

    def push_notificable?
      return false if device_tokens_count.blank?

      device_tokens_count.positive?
    end

    def email_required?
      phone_number.blank?
    end

    def validate_current_password!(password)
      return if valid_password?(password)

      errors.add(:password, I18n.t('spree_user.invalid_password'))
    end
  end
end

Spree::User.prepend(SpreeCmCommissioner::UserDecorator) unless Spree::User.included_modules.include?(SpreeCmCommissioner::UserDecorator)

# rubocop:enable Metrics/MethodLength
