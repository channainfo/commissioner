module SpreeCmCommissioner
  class CustomerNotificationCronJob < ApplicationJob
    queue_as :default

    def perform
      SpreeCmCommissioner::CustomerNotificationCronExecutor.call
    end
  end
end
