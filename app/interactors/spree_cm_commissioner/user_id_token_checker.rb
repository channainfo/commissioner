module SpreeCmCommissioner
  class UserIdTokenChecker < BaseInteractor

    # :id_token
    def call
      firebase_id_token_context = SpreeCmCommissioner::FirebaseIdTokenProvider.call(id_token: context.id_token)

      if firebase_id_token_context.success?
        validate_user_by_provider(firebase_id_token_context.provider)
      else
        context.fail!(message: firebase_id_token_context.message)
      end
    end

    # :identity_type, :sub
    def validate_user_by_provider(provider)
      identity_checker = SpreeCmCommissioner::UserIdentityChecker.call(provider)
      if identity_checker.success?
        context.user = identity_checker.user
      else
        context.fail!(message: identity_checker.message)
      end
    end
  end
end