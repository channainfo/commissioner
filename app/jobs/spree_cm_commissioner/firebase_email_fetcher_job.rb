module SpreeCmCommissioner
  class FirebaseEmailFetcherJob < ApplicationJob
    queue_as :default

    def perform
      SpreeCmCommissioner::FirebaseEmailFetcherCronExecutor.call
    end
  end
end
