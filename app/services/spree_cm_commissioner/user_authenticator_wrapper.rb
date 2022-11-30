# Raise exception here instead of interactor

module SpreeCmCommissioner
  class UserAuthenticatorWrapper
    # :id_token
    # :login, :password
    def self.call?(params)
      options = {
        id_token: params[:id_token],
        password: params[:password],
        login: params[:username],
      }

      auth = SpreeCmCommissioner::UserAuthenticator.call(options)
      auth.user
    end
  end
end