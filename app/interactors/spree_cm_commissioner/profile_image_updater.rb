module SpreeCmCommissioner
  class ProfileImageUpdater < BaseInteractor
    # url: 'https://mybucket.s3.ap-southeast-1.amazonaws.com/uploads/5f31/1697038252270.jpg'
    def call
      presigned_url = SpreeCmCommissioner::S3UrlGenerator.s3_presigned_url(context.url)

      response = Faraday.get(presigned_url)

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
