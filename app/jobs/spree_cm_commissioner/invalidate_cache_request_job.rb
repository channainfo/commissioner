module SpreeCmCommissioner
  class InvalidateCacheRequestJob < ApplicationUniqueJob
    def perform(pattern)
      SpreeCmCommissioner::InvalidateCacheRequest.call(pattern: pattern)
    end
  end
end
