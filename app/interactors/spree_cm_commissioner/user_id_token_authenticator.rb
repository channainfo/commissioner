module SpreeCmCommissioner
  class UserIdTokenAuthenticator < BaseInteractor
    # :id_token
    def call
      context.user = if checker.user.nil?
                       register_user
                     else
                       checker.user
                     end

      update_user_email if context.user.email.blank?

      context.fail!(message: 'account_temporarily_deleted') if context.user.soft_deleted?
    end

    def register_user
      register_context = SpreeCmCommissioner::UserRegistrationWithIdToken.call(id_token: context.id_token)
      register_context.user
    end

    def update_user_email
      firebase_context = FirebaseIdTokenProvider.call(id_token: context.id_token)
      return unless firebase_context.success?

      email = firebase_context.provider[:email]
      context.user.update(email: email) if email.present?
    end

    def checker
      @checker ||= SpreeCmCommissioner::UserIdTokenChecker.call(id_token: context.id_token)
      @checker
    end
  end
end
