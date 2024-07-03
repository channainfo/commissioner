module SpreeCmCommissioner
  class UniqueDeviceTokenCronJob < ApplicationJob
    queue_as :default

    def perform
      SpreeCmCommissioner::UniqueDeviceTokenCronExecutor.call
    end
  end
end
