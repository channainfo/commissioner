module SpreeCmCommissioner
  class AccountChecker < BaseInteractor

    # :login
    # :id_token
    def call
      if context.login.present?
        context.user = Spree.user_class.find_for_database_authentication(email: context.login)
        context.fail!(message: I18n.t('account_checker.login_not_found', login: context.login)) if context.user.nil?
      elsif context.id_token.present?
        auth_context = UserIdTokenChecker.call(id_token: context.id_token)
        context.fail!(message: auth_context.message) unless auth_context.success?
        context.user = auth_context.user
      end
    end
  end
end
