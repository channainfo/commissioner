module SpreeCmCommissioner
  class UserRegistrationWithSocial < BaseInteractor

    # :id_token
    def call
      firebase_context = SpreeCmCommissioner::FirebaseIdTokenProvider.call(id_token: context.id_token)
  
      if firebase_context.success?
        ActiveRecord::Base.transaction do
          register_user!
          link_user_account!(firebase_context.provider)
        end
      else
        context.fail!(message: firebase_context.message)
      end
    end
  
    def register_user!
      user = Spree.user_class.new(password: SecureRandom.base64(16))
  
      if user.save :validate => false
        context.user = user
      else
        context.fail!(message: user.errors.full_messages.join('\n'))
      end
    end
  
    # provider object
  
    # {
    #   provider_name: provider_name,
    #   email: email,
    #   sub: sub
    # }
  
    def link_user_account!(provider)
      identity_name = provider[:provider_name]
      identity_type = SpreeCmCommissioner::UserIdentityProvider.identity_types[identity_name]
      
      user_identity_provider = SpreeCmCommissioner::UserIdentityProvider.where(
        user_id: context.user, 
        identity_type: identity_type
      ).first_or_initialize
     
      user_identity_provider.sub = provider[:sub]
      user_identity_provider.email = provider[:email]
  
      if user_identity_provider.save
        context.user_identity_provider = user_identity_provider
      else
        context.fail!(message: user_identity_provider.errors.full_messages)
      end
    end
  end
end