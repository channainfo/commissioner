module SpreeCmCommissioner
  class UserVattanacBankWebAppAuthenticator < BaseInteractor
    delegate :session_id, to: :context

    def call
      return context.fail!(message: 'Invalid token') unless payload
      return context.fail!(message: 'User not found') unless user

      verify_token!

      context.user = user
    rescue JWT::DecodeError => e
      context.fail!(message: "Decode error: #{e.message}")
    end

    private

    def payload
      @payload ||= SpreeCmCommissioner::UserSessionJwtToken.decode(session_id)
    end

    def user
      @user ||= Spree::User.find_by(id: payload['user_id']) if payload
    end

    def verify_token!
      SpreeCmCommissioner::UserSessionJwtToken.decode(session_id, user.secure_token)
    end
  end
end
