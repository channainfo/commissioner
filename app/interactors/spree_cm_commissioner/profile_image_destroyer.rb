module SpreeCmCommissioner
  class ProfileImageDestroyer < BaseInteractor
    delegate :user, to: :context

    def call
      profile_image = SpreeCmCommissioner::UserProfile.find_by(viewable: user)

      if profile_image
        profile_image.destroy
        context.result = profile_image
      else
        context.fail!(message: 'No profile image to delete')
      end
    end
  end
end
