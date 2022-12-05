# In case we need to raise exception.
module SpreeCmCommissioner
  class UserAuthenticator

    # :username, :password
    # :id_token
    def self.call?(params)
      context = auth_context(params)
      raise exception(context.message) unless context.success?
      context.user
    end

    private

    def self.auth_context(params)
      case flow_type(params)
      when 'email_auth'
        options = { login: params[:username], password: params[:password] }
        SpreeCmCommissioner::UserPasswordAuthenticator.call(options)
      when 'social_auth'
        options = { id_token: params[:id_token] }
        SpreeCmCommissioner::UserIdTokenAuthenticator.call(options)
      end
    end

    def self.flow_type(params)
      return 'email_auth' if params.include?('username') && params.include?('password')
      return 'social_auth' if params.include?('id_token')

      raise exception(I18n.t('authenticator.invalid_or_missing_params'))
    end

    def self.exception(message)
      Doorkeeper::Errors::DoorkeeperError.new(message)
    end
  end
end