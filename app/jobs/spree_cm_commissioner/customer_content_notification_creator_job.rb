module SpreeCmCommissioner
  class CustomerContentNotificationCreatorJob < ApplicationJob
    def perform(options)
      SpreeCmCommissioner::CustomerContentNotificationCreator.new(options).call
    end
  end
end
