module SpreeCmCommissioner
  class ProfileImageUpdater < BaseInteractor
    def call
      response = Faraday.get(context.url)

      if response.success?
        user = context.user
        io = StringIO.new(response.body)
        filename = File.basename(context.url)

        profile = user.profile || SpreeCmCommissioner::UserProfile.new(viewable: user)

        profile.attachment.attach(io: io, filename: filename)

        if profile.save
          context.result = profile
        else
          context.fail!(message: profile.errors.full_messages.join(','))
        end
      end
    rescue StandardError => e
      context.fail!(message: "Error fetching the remote image: #{e.message}")
    end
  end
end
