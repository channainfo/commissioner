module SpreeCmCommissioner
  class UserPasswordAuthenticator < BaseInteractor

    # :login, :password
    def call
      context.user = Spree.user_class.find_for_database_authentication(email: login)

      context.fail!(message: I18n.t('authenticator.incorrect_login')) if context.user.nil?
      context.fail!(message: I18n.t('authenticator.incorrect_password')) if spree_confirmable? && active_for_authentication? && !validate_password(user)
      context.fail!(message: I18n.t('authenticator.incorrect_password')) unless validate_password(context.user)
    end

    private

    def validate_password(user)
      user.valid_for_authentication? { user.valid_password?(password) }
    end

    def spree_confirmable?
      defined?(Spree::Auth::Config) && Spree::Auth::Config[:confirmable] == true
    end

    def active_for_authentication?
      user.active_for_authentication?
    end

    def login
      context.login
    end

    def password
      context.password
    end
  end
end
