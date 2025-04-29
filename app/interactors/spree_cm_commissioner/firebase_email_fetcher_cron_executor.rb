module SpreeCmCommissioner
  class FirebaseEmailFetcherCronExecutor < BaseInteractor
    def call
      users = Spree::User.includes(:google_user_identity_providers)
                         .joins(:google_user_identity_providers)
                         .where(email: nil)

      users.find_each do |user|
        google_identity = user.google_user_identity_providers.first
        firebase_user = SpreeCmCommissioner::FirebaseEmailFetcher.call(sub: google_identity.sub)
        next unless firebase_user.success?

        email = firebase_user.email

        next if email.blank?
        next if Spree::User.exists?(email: email)

        google_identity.update(email: email)
        user.update(email: email)
      end
    end
  end
end
