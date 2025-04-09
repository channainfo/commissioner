module SpreeCmCommissioner
  class ExistingAccountChecker
    include Interactor

    def call
      user = Spree.user_class.find_user_by_login(context.login, context.tenant_id) if context.login.present?

      context.fail!(message: I18n.t('account_checker.verify.already_exist', login: context.login)) if user.present?
    end
  end
end
