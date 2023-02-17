module SpreeCmCommissioner
  class UserIdTokenAuthenticator < BaseInteractor
    # :id_token
    def call
      context.user = if checker.user.nil?
                       register_user
                     else
                       checker.user
                     end
    end

    def register_user
      register_context = SpreeCmCommissioner::UserRegistrationWithIdToken.call(id_token: context.id_token)
      register_context.user
    end

    def checker
      @checker ||= SpreeCmCommissioner::UserIdTokenChecker.call(id_token: context.id_token)
      @checker
    end
  end
end
