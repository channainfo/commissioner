module SpreeCmCommissioner
  module UserIdentity
    extend ActiveSupport::Concern

    included do
      include SpreeCmCommissioner::PhoneNumberSanitizer

      has_many :user_identity_providers, dependent: :destroy, class_name: 'SpreeCmCommissioner::UserIdentityProvider'

      validates :user_identity_providers, presence: true, if: -> (u) { u.require_login_identity_all_blank_for(:user_identity_providers) }

      validates :phone_number, presence: true, if: -> (u) { u.require_login_identity_all_blank_for(:phone_number) }
      validates :phone_number, uniqueness: { allow_blank: true }
      validates :phone_number, format: { with: /^\d{8,12}$/, :multiline => true, allow_blank: true }

      validates :login, presence: true, if: -> (u) { u.require_login_identity_all_blank_for(:login) }
      validates :login, uniqueness: { case_sensitive: false, allow_blank: true }
    end

    class_methods do
      def find_user_by_login(login)
        return nil if login.blank?

        login = login.downcase
        parser = PhoneNumberParser.call(phone_number: login)

        if parser.intel_phone_number.present?
          find_by(intel_phone_number: parser.intel_phone_number)
        elsif login =~ URI::MailTo::EMAIL_REGEXP
          find_by(email: login)
        else
          find_by(login: login)
        end
      end
    end

    # override:spree_auth_devise:app/models/spree/user.rb
    # set_login is ran before validation.
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
      requierd_fields = %i[phone_number email user_identity_providers login].reject { |item| item == field }
      requierd_fields.each do |requierd_field|
        return false if send(requierd_field).present?
      end
      true
    end
  end
end
