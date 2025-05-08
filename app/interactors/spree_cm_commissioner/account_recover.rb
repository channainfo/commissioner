module SpreeCmCommissioner
  class AccountRecover < BaseInteractor
    delegate :id_token, :login, :password, :tenant_id, to: :context

    def call
      validate_user
      recover_user
    end

    def recover_user
      updated = context.user.update(account_deletion_at: nil, account_restored_at: Time.current)
      context.fail!(message: user.errors.full_messages.to_sentence) unless updated
    end

    def validate_user
      # get email password user
      if login.present? && password.present?
        context.user = Spree.user_class.find_user_by_login(login, tenant_id)
      # get social user
      elsif id_token.present?
        checker_context = SpreeCmCommissioner::UserIdTokenChecker.call(id_token: id_token)
        context.user = checker_context.user
      end

      if context.user.present?
        context.fail!(message: 'User is not temporary deleted') unless context.user.soft_deleted?
      else
        context.fail!(message: 'User is not valid')
      end
    end
  end
end
