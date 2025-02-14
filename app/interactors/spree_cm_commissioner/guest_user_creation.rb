module SpreeCmCommissioner
  class GuestUserCreation < BaseInteractor
    def call
      create_user!
    end

    def create_user!
      user = Spree::User.create!(
        email: "guest_#{SecureRandom.hex(24)}@example.com",
        guest: true,
        confirmed_at: Time.zone.now,
        secure_token: SecureRandom.uuid,
        password: SecureRandom.urlsafe_base64(12)
      )

      context.result = user
    end
  end
end
