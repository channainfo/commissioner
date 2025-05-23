module SpreeCmCommissioner
  class UserRegistrationWithIdToken < BaseInteractor
    # :id_token
    def call
      firebase_context = SpreeCmCommissioner::FirebaseIdTokenProvider.call(id_token: context.id_token)

      if firebase_context.success?
        ActiveRecord::Base.transaction do
          register_user!(firebase_context.provider[:name], firebase_context.provider[:email])
          link_user_account!(firebase_context.provider)
        end
      else
        context.fail!(message: firebase_context.message)
      end
    end

    def register_user!(name, email)
      user = Spree.user_class.new(password: SecureRandom.base64(16), email: email, **name_attributes(name))
      if user.save(validate: false)
        context.user = user
      else
        context.fail!(message: user.errors.full_messages.join('\n'))
      end
    end

    def name_attributes(name)
      full_name = name&.strip
      return {} if full_name.blank?

      split = full_name.split
      first_name = split[0]
      last_name = split[1..].join(' ')

      attributes = {}
      attributes[:first_name] = first_name if first_name.present?
      attributes[:last_name] = last_name if last_name.present?

      attributes
    end

    # provider object

    # {
    #   identity_type: identity_type,
    #   sub: sub
    # }

    def link_user_account!(provider)
      identity_type = SpreeCmCommissioner::UserIdentityProvider.identity_types[provider[:identity_type]]

      user_identity_provider = SpreeCmCommissioner::UserIdentityProvider.where(
        user_id: context.user,
        identity_type: identity_type
      ).first_or_initialize

      user_identity_provider.sub = provider[:sub]
      user_identity_provider.email = provider[:email]
      user_identity_provider.name = provider[:name]

      if user_identity_provider.save
        context.user_identity_provider = user_identity_provider
      else
        context.fail!(message: user_identity_provider.errors.full_messages)
      end
    end
  end
end
