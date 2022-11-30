module SpreeCmCommissioner
  class UserAuthenticator < BaseInteractor

    # :id_token
    # :login, :password
    def call  
      result = if id_token.present?
        SpreeCmCommissioner::UserIdTokenAuthenticator.call(id_token: id_token) if id_token.present?
      else
        SpreeCmCommissioner::UserPasswordAuthenticator.call(login: login, password: password)
      end
      
      p "###############"
      p result

      context.user = result.user
      return context.fail!(message: result.message) unless result.success?
    end

    private

    def id_token
      context.id_token
    end

    def login
      context.login
    end

    def password
      context.password
    end
  end
end