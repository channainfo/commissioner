require 'firebase-admin-sdk'

module SpreeCmCommissioner
  class FirebaseEmailFetcher < BaseInteractor
    delegate :user_id, :sub, to: :context

    # Firebase response
    # {
    #   "localId" => "8AGwn0V88kP7vkticwuYZkNNoIJ2",
    #   "displayName" => "Sreyleak Deth",
    #   "photoUrl" => "https://lh3.googleusercontent.com/a/ACg8ocIkL62VaxNb7bOAXV30sZOGQ_Dw7ZYvlBH-Hk2jm3swNg=s96-c",
    #   "providerUserInfo" => [
    #     {
    #       "providerId" => "google.com",
    #       "displayName" => "Sreyleak Deth",
    #       "photoUrl" => "https://lh3.googleusercontent.com/a/ACg8ocK88Fm3GhVeCS98vLGE-vmShSi76xZwYYA1QwImuyck7zAqpR0=s96-c",
    #       "federatedId" => "109192493976909808585",
    #       "email" => "sreyleak.deth19@gmail.com",
    #       "rawId" => "109192493976909808585"
    #     }
    #   ],
    #   "validSince" => "1707378937",
    #   "lastLoginAt" => "1739440924021",
    #   "createdAt" => "1707378937388",
    #   "lastRefreshAt" => "2025-04-01T08:54:24.480031Z"
    # }

    def call
      @manager = initialize_firebase_manager

      if context.user_id.present?
        user = @manager.get_user_by(uid: context.user_id)
      elsif context.sub.present?
        user = @manager.get_user_by_sub(sub: context.sub)
      end

      context.email = user.provider_data.first&.email
    end

    private

    def service_account
      @service_account ||= Rails.application.credentials.cloud_firestore_service_account
    end

    def initialize_firebase_manager
      @credentials ||= Firebase::Admin::Credentials.from_json(service_account.to_json)
      Firebase::Admin::Auth::UserManager.new(service_account[:project_id], @credentials)
    end
  end
end
