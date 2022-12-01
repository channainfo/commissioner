# In case we need to raise exception.
module SpreeCmCommissioner
  class UserAuthenticator

    # :login, :password
    def self.call?(params)
      grant_type = params['grant_type']

      case grant_type
      when 'password'
        options = { login: params[:username], password: params[:password] }
        context = SpreeCmCommissioner::UserPasswordAuthenticator.call(options)
      end

      raise Doorkeeper::Errors::DoorkeeperError.new(context.message) unless context.success?
      context.user
    end
  end
end