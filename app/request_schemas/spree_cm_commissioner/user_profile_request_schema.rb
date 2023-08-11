module SpreeCmCommissioner
  class UserProfileRequestSchema < ApplicationRequestSchema
    params do
      optional(:first_name).filled(:string)
      optional(:last_name).filled(:string)
    end
  end
end
