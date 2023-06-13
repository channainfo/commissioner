module SpreeCmCommissioner
  class CustomerNotificationCron < ApplicationJob
    def perform
      SpreeCmCommissioner::CustomerNotificationCronExecutor.call unless Rails.env.development?
    end
  end
end
