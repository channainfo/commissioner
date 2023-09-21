module SpreeCmCommissioner
  class UserAccountLinkageRequestSchema < ApplicationRequestSchema
    params do
      required(:id_token).filled(:string)
    end
  end
end
