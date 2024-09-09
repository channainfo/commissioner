module SpreeCmCommissioner
  class SubscriptionOrderExecutorJob < ApplicationJob
    def perform
      SubscriptionsOrderCronExecutor.call
    end
  end
end
