module SpreeCmCommissioner
  class OauthTokenGenerator < BaseInteractor 
    # :application, :resource_owner
    def call
      access_token = Spree::OauthAccessToken.create_for(
        application: context.application,
        resource_owner: context.resource_owner,
        scopes: 'public',
        expires_in: 3600 * 2,
        use_refresh_token: true,
      )
  
      if access_token
        context.token_response = Doorkeeper::OAuth::TokenResponse.new(access_token).body
      else
        context.fail!(message: token.errors.full_messages.join("\n"))
      end
    end
  end
end
