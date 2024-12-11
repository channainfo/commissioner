require 'google/cloud/firestore'

class FirestoreClient
  def self.instance
    @instance ||= Google::Cloud::Firestore.new(
      project_id: service_account[:project_id],
      credentials: service_account
    )
  end

  def self.service_account
    @service_account ||= Rails.application.credentials.cloud_firestore_service_account
  end
end
