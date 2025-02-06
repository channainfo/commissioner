module SpreeCmCommissioner
  class UserIdentityChecker < BaseInteractor
    # :identity_type, :sub
    def call
      load_user

      return unless context.user.nil?

      error_message = I18n.t('user_identity_provider.not_found', identity_type: context.identity_type)
      context.fail!(message: error_message)
    end

    def load_user
      user_identity_provider = UserIdentityProvider.where(
        identity_type: context.identity_type,
        sub: context.sub
      ).first

      if user_identity_provider.present? && user_identity_provider.user.email.nil? && user_identity_provider.email.present?
        user_identity_provider.user.email = user_identity_provider.email
        user_identity_provider.user.save
      end

      context.user = (user_identity_provider.user if user_identity_provider.present?)
    end
  end
end
