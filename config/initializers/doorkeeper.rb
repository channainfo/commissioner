Doorkeeper.configure do
  orm :active_record
  use_refresh_token
  api_only
  base_controller 'Spree::Api::V2::BaseController'
  base_metal_controller 'Spree::Api::V2::BaseController'

  # FIXME: we should only skip this for Storefront API until v5
  # we should not skip this for Platform API
  skip_client_authentication_for_password_grant { true } if defined?(skip_client_authentication_for_password_grant)

  resource_owner_authenticator { current_spree_user }
  use_polymorphic_resource_owner

  resource_owner_from_credentials do
    user = SpreeCmCommissioner::UserAuthenticator.call?(params)
    user
  end

  admin_authenticator do |routes|
    current_spree_user&.spree_admin? || redirect_to(routes.root_url)
  end

  grant_flows %w[password client_credentials]

  allow_blank_redirect_uri true

  handle_auth_errors :raise

  access_token_methods :from_bearer_authorization, :from_access_token_param

  optional_scopes :admin, :write, :read

  access_token_class 'Spree::OauthAccessToken'
  access_grant_class 'Spree::OauthAccessGrant'
  application_class 'Spree::OauthApplication'

  # using Bcrupt for token secrets is currently not supported by Doorkeeper
  hash_token_secrets fallback: :plain
  hash_application_secrets fallback: :plain, using: '::Doorkeeper::SecretStoring::BCrypt'


  # custom configuration https://github.com/doorkeeper-gem/doorkeeper/wiki/Customizing-Token-Expiration
  custom_access_token_expires_in do |context|
    # context.grant_type for grant_type, context.client for client, context.scopes for scopes
    if context.grant_type == Doorkeeper::OAuth::CLIENT_CREDENTIALS # see Doorkeeper::OAuth::GRANT_TYPES for other types
      7.days.to_i
    elsif context.grant_type == Doorkeeper::OAuth::PASSWORD
      1.year.to_i
    else
      2.hours.to_i
    end
  end
end
