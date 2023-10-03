module SpreeCmCommissioner
  module OauthAccessTokenDecorator
    def revoke_previous_refresh_token!
      ActiveRecord::Base.connected_to(role: :writing) do
        super
      end
    end
  end
end

unless Spree::OauthAccessToken.included_modules.include?(SpreeCmCommissioner::OauthAccessTokenDecorator)
  Spree::OauthAccessToken.prepend(SpreeCmCommissioner::OauthAccessTokenDecorator)
end
