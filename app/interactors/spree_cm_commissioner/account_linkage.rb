module SpreeCmCommissioner
  class AccountLinkage
    include Interactor

    # id_token:, user:
    def call
      firebase_id_token_context = FirebaseIdTokenProvider.call(id_token: context.id_token)

      if firebase_id_token_context.success?
        build_user_identify_provider(firebase_id_token_context.provider)
      else
        context.fail!(message: firebase_id_token_context.message)
      end
    end

    private

    # {
    #   provider_name: provider_name,
    #   email: email,
    #   sub: sub
    # }
    def build_user_identify_provider(provider)
      identity_type = provider[:identity_type]

      identity_type = UserIdentityProvider.identity_types[identity_type]

      identity_provider = UserIdentityProvider
                          .where(user_id: context.user, identity_type: identity_type)
                          .first_or_initialize

      identity_provider.sub = provider[:sub]
      identity_provider.email = provider[:email]

      if identity_provider.save
        context.identity_provider = identity_provider
      else
        context.identity_provider = identity_provider

        error = context.identity_provider.errors.full_messages.join(',')
        message = I18n.t('account_link.failure', identity_type: identity_provider.identity_type.to_s, reason: error)
        context.fail!(message: message)
      end
    end
  end
end
