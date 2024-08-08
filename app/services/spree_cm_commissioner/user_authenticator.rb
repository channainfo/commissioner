# In case we need to raise exception.
module SpreeCmCommissioner
  class UserAuthenticator
    # :username, :password
    # :id_token
    def self.call!(params)
      context = auth_context(params)
      raise exception(context.message) unless context.success?

      context.user
    end

    def self.auth_context(params)
      case flow_type(params)
      when 'login_auth'
        options = { login: params[:username], password: params[:password] }
        SpreeCmCommissioner::UserPasswordAuthenticator.call(options)
      when 'social_auth'
        options = { id_token: params[:id_token] }
        SpreeCmCommissioner::UserIdTokenAuthenticator.call(options)
      when 'telegram_web_app_auth'
        options = { telegram_init_data: params[:telegram_init_data] }
        SpreeCmCommissioner::UserTelegramWebAppAuthenticator.call(options)
      end
    end

    def self.flow_type(params)
      return 'login_auth' if params.key?(:username) && params.key?(:password)
      return 'social_auth' if params.key?(:id_token)
      return 'telegram_web_app_auth' if params.key?(:telegram_init_data)

      raise exception(I18n.t('authenticator.invalid_or_missing_params'))
    end

    def self.exception(message)
      Doorkeeper::Errors::DoorkeeperError.new(message)
    end
  end
end
