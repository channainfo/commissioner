module SpreeCmCommissioner
  class InvalidateCacheRequestJob < ApplicationJob
    def perform(pattern)
      SpreeCmCommissioner::InvalidateCacheRequest.call(pattern: pattern)
    end
  end
end
