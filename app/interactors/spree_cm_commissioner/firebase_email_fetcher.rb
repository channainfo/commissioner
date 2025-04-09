require 'firebase-admin-sdk'

module SpreeCmCommissioner
  class FirebaseEmailFetcher < BaseInteractor
    delegate :user_id, to: :context

    def call
      manager = initialize_firebase_manager
      user = manager.get_user_by(uid: context.user_id)

      context.email = user.provider_data.first&.email
    end

    private

    def service_account
      @service_account ||= Rails.application.credentials.cloud_firestore_service_account
    end

    def initialize_firebase_manager
      @credentials ||= Firebase::Admin::Credentials.from_json(service_account.to_json)
      @manager ||= Firebase::Admin::Auth::UserManager.new(service_account[:project_id], @credentials)
    end
  end
end
