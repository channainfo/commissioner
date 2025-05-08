module SpreeCmCommissioner
  module UserIdentity
    extend ActiveSupport::Concern

    included do
      include SpreeCmCommissioner::PhoneNumberSanitizer

      has_many :user_identity_providers, dependent: :destroy, class_name: 'SpreeCmCommissioner::UserIdentityProvider'

      validates :user_identity_providers, presence: true, if: -> (u) { u.require_login_identity_all_blank_for(:user_identity_providers) }

      validates :phone_number, presence: true, if: -> (u) { u.require_login_identity_all_blank_for(:phone_number) }
      validates :phone_number, uniqueness: { scope: :tenant_id, allow_blank: true }
      validates :phone_number, format: { with: /^\d{8,12}$/, :multiline => true, allow_blank: true }

      validates :login, presence: true, if: -> (u) { u.require_login_identity_all_blank_for(:login) }
      validates :login, uniqueness: { scope: :tenant_id, case_sensitive: false, allow_blank: true }

      _validators.reject! { |key, _| key == :email }
      _validate_callbacks.each { |c| c.filter.attributes.delete(:email) if c.filter.respond_to?(:attributes) }

      validates :email, presence: true, if: -> (u) { u.require_login_identity_all_blank_for(:email) }
      validates :email, uniqueness: { scope: :tenant_id, case_sensitive: false, allow_blank: true }
      validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
    end

    class_methods do
      def find_user_by_login(login, tenant_id)
        return nil if login.blank?

        login = login.downcase
        parser = PhoneNumberParser.call(phone_number: login)

        scope = Spree.user_class.all
        scope = scope.where(tenant_id: tenant_id) if tenant_id.present?

        if parser.intel_phone_number.present?
          scope.find_by(intel_phone_number: parser.intel_phone_number)
        elsif login =~ URI::MailTo::EMAIL_REGEXP
          scope.find_by(email: login)
        else
          scope.find_by(login: login)
        end
      end
    end

    # override:spree_auth_devise:app/models/spree/user.rb
    def set_login
      self.login ||= phone_number if phone_number
      self.login ||= email if email
    end

    # override:devise:lib/devise/models/validatable.rb
    def email_required?
      require_login_identity_all_blank_for(:email)
    end

    protected

    def require_login_identity_all_blank_for(field)
      required_fields = %i[phone_number email user_identity_providers login].reject { |item| item == field }
      required_fields.each do |required_field|
        return false if send(required_field).present?
      end
      true
    end
  end
end
