module SpreeCmCommissioner
  class UserPasswordAuthenticator < BaseInteractor
    delegate :login, :password, :tenant_id, to: :context

    def call
      context.user = Spree.user_class.find_user_by_login(login, tenant_id)
      context.fail!(message: I18n.t('authenticator.incorrect_login')) if context.user.nil?

      if spree_confirmable? && active_for_authentication? && !validate_password(user)
        context.fail!(message: I18n.t('authenticator.incorrect_password'))
      end

      context.fail!(message: I18n.t('authenticator.incorrect_password')) unless validate_password(context.user)
      context.fail!(message: 'account_temporarily_deleted') if context.user.soft_deleted?
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
  end
end
