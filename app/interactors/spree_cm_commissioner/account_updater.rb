module SpreeCmCommissioner
  class AccountUpdater < BaseInteractor
    delegate :user, to: :context
    delegate :options, to: :context
    def call
      update_account
    end

    def update_account
      ok = user.update(options)
      context.fail!(message: user.errors.full_messages.join(',')) unless ok
    end
  end
end
