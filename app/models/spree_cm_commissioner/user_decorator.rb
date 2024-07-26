# rubocop:disable Metrics/MethodLength
module SpreeCmCommissioner
  module UserDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::UserNotification
      base.include SpreeCmCommissioner::UserIdentity
      base.include SpreeCmCommissioner::UserPreference

      base.enum gender: %i[male female other]

      base.has_many :subscriptions, through: :customer, class_name: 'SpreeCmCommissioner::Subscription'
      base.has_many :payments, as: :payable, class_name: 'Spree::Payment', dependent: :nullify
      base.has_many :role_permissions, through: :spree_roles, class_name: 'SpreeCmCommissioner::RolePermission'
      base.has_many :permissions, through: :role_permissions, class_name: 'SpreeCmCommissioner::Permission'
      base.has_many :line_items, through: :orders, source: :line_items
      base.has_many :check_ins, foreign_key: 'check_in_by_id', class_name: 'SpreeCmCommissioner::CheckIn'
      base.has_many :user_events, class_name: 'SpreeCmCommissioner::UserEvent'
      base.has_many :events, through: :user_events, class_name: 'Spree::Taxon', source: 'taxon'

      base.has_many :wished_items, class_name: 'Spree::WishedItem', through: :wishlists
      base.has_many :promotions, through: :promotion_rules, class_name: 'Spree::Promotion'

      base.has_one :profile, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::UserProfile'
      base.has_one :customer, class_name: 'SpreeCmCommissioner::Customer'

      base.has_secure_password :confirm_pin_code, validations: false

      base.whitelisted_ransackable_attributes = %w[email first_name last_name gender phone_number]

      base.before_save :update_otp_enabled

      define_user_places(base)

      def base.end_users
        joins('LEFT JOIN spree_vendor_users ON spree_users.id = spree_vendor_users.user_id').where(spree_vendor_users: { user_id: nil })
      end

      def normal_user?
        system_user = admin? || !vendors.empty?
        normal_user = spree_roles.length == 1 ? spree_roles[0].name == 'user' : spree_roles.empty?
        normal_user && !system_user
      end

      def soft_deleted?
        !account_deletion_at.nil?
      end
    end

    def self.define_user_places(base)
      base.has_many :user_places, class_name: 'SpreeCmCommissioner::UserPlace'
      base.has_many :places, through: :user_places, class_name: 'SpreeCmCommissioner::Place'
    end

    def super_admin?
      has_spree_role?('super_admin')
    end

    def early_adopter?
      has_spree_role?('early_adopter')
    end

    def organizer?
      has_spree_role?('organizer')
    end

    def full_name
      [first_name, last_name].compact_blank.join(' ')
    end

    def display_name
      return full_name if full_name.present?
      return first_name if first_name.present?
      return last_name if last_name.present?
      return email if email.present?

      phone_number
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

      if notification.persisted?
        notification.update(attributes)
      else
        notification.assign_attributes(attributes)
        notification.save!
      end

      notification
    end

    def push_notificable?
      return false if device_tokens_count.blank?

      device_tokens_count.positive?
    end

    def validate_current_password!(password)
      return if valid_password?(password)

      errors.add(:password, I18n.t('spree_user.invalid_password'))
    end

    def update_otp_enabled
      self.otp_enabled = otp_email || otp_phone_number
    end
  end
end

Spree::User.prepend(SpreeCmCommissioner::UserDecorator) unless Spree::User.included_modules.include?(SpreeCmCommissioner::UserDecorator)
# rubocop:enable Metrics/MethodLength
