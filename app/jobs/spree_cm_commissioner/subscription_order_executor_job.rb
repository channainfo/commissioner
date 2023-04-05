module SpreeCmCommissioner
  class SubscriptionOrderExecutorJob < ApplicationJob
    def perform
      SubscriptionOrderCronExecutor.call
    end
  end
end
