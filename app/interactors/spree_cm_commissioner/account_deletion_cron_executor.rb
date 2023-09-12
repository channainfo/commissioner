module SpreeCmCommissioner
  class AccountDeletionCronExecutor < BaseInteractor
    def call
      user_soft_deleted_accounts.find_each do |user_soft_deleted_account|
        delete_account_permanently(user_soft_deleted_account)
      end
    end

    def user_soft_deleted_accounts
      deleted_time = 1.month.ago
      Spree::User.with_deleted.where(['deleted_at IS NOT NULL AND deleted_at < ?', deleted_time])
    end

    def delete_account_permanently(user_soft_deleted_account)
      user_soft_deleted_account.really_delete
    end
  end
end
