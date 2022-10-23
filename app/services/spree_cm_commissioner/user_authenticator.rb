# In case we need to raise exception.
module SpreeCmCommissioner
  class UserAuthenticator

    # :login, :password
    # :id_token
    def self.call?(params)
      context = authenticate(params)

      raise exception(context) unless context.success?
      context.user
    end

    private

    def self.authenticate(params)
      grant_type = params[:grant_type]

      case grant_type
      when 'password'
        options = { login: params[:username], password: params[:password] }
        SpreeCmCommissioner::UserPasswordAuthenticator.call(options)
      when 'assertion'
        options = { id_token: params[:id_token] }
        SpreeCmCommissioner::UserIdTokenAuthenticator.call(options)
      end
    end

    def self.exception(context)
      Doorkeeper::Errors::DoorkeeperError.new(context.message)
    end
  end
end