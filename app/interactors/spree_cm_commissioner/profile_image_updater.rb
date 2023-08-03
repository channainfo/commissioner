module SpreeCmCommissioner
  class ProfileImageUpdater < BaseInteractor
    def call
      begin
        io = File.open(context.url)
      rescue StandardError => e
        context.fail!(message: e.message)
      end

      user = context.user
      profile = user.profile || SpreeCmCommissioner::UserProfile.new(viewable: user)

      filename = context.url.split('/').last
      profile.attachment.attach(io: io, filename: filename)

      if profile.save
        context.result = profile
      else
        context.fail!(message: profile.errors.full_messages.join(','))
      end
    end
  end
end
