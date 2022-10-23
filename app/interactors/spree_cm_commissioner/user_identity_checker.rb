module SpreeCmCommissioner
  class UserIdentityChecker < BaseInteractor

    # :identity_type, :sub
    def call
      load_user

      if(context.user.nil?)
        error_message = I18n.t('user_identity_provider.not_found', identity_type: context.identity_type)
        context.fail!(message: error_message)
      end
    end

    def load_user
      p UserIdentityProvider.all
      user_identity_provider = UserIdentityProvider.where(
        identity_type: context.identity_type, 
        sub: context.sub
      ).first

      if user_identity_provider.present?
        context.user = user_identity_provider.user
      else
        context.user = nil
      end
    end
  end
end