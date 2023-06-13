module SpreeCmCommissioner
  class CustomerNotificationCron < ApplicationJob
    def perform
      SpreeCmCommissioner::CustomerNotificationCronExecutor.call
    end
  end
end
