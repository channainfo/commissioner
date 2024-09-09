module SpreeCmCommissioner
  class AccountDeletionCronJob < ApplicationJob
    def perform
      SpreeCmCommissioner::AccountDeletionCronExecutor.call
    end
  end
end
