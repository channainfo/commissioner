module SpreeCmCommissioner
  class SubscriptionOrderExecutorJob < ApplicationJob
    def perform
      SubscriptionsOrderCronExecutor.call
      logger.info 'SubscriptionOrderExecutorJob done'
      logger.debug { 'My args: tykeaboyloy' }
    end
  end
end
