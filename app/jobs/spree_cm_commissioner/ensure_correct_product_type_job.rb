module SpreeCmCommissioner
  class EnsureCorrectProductTypeJob < ApplicationJob
    def perform
      SpreeCmCommissioner::EnsureCorrectProductType.call
    end
  end
end
