module SpreeCmCommissioner
  class CustomerContentNotificationCreatorJob < ApplicationUniqueJob
    def perform(options)
      SpreeCmCommissioner::CustomerContentNotificationCreator.new(options).call
    end
  end
end
