module SpreeCmCommissioner
  class UserIdentityChecker < BaseInteractor

    # :identity_type, :email, :sub
    def call
      load_user

      if(context.user.nil?)
        error_message = I18n.t('user_identity_provider.not_found', identity_type: context.identity_type)
        context.fail!(message: error_message)
      end
    end

    def load_user
      identity_options = { identity_type: UserIdentityProvider.identity_types[context.identity_type], sub: context.sub }
      user_identity_provider = UserIdentityProvider.where(identity_options).first

      if user_identity_provider.present?
        context.user = user_identity_provider.user
      elsif context.email.present?
        context.user = Spree.user_class.find_by(email: context.email)
      else
        context.user = nil
      end
    end
  end
end
