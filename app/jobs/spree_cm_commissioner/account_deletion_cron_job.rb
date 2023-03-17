module SpreeCmCommissioner
  class AccountDeletionCronJob < ApplicationJob
    def perform
      AccountDeletionCronExecutor.call
    end
  end
end
