module SpreeCmCommissioner
  class SubscriptionOrderExecutorJob < ApplicationJob
    queue_as :default

    def perform
      SpreeCmCommissioner::SubscriptionsOrderCronExecutor.call
    end
  end
end
