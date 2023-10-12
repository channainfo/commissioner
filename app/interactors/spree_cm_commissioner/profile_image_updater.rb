module SpreeCmCommissioner
  class ProfileImageUpdater < BaseInteractor
    # url: 'https://mybucket.s3.ap-southeast-1.amazonaws.com/uploads/5f31/1697038252270.jpg'
    def call
      key = context.url.split('amazonaws.com/').last
      presigned_url = s3_presigned_url(key)
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

    # https://docs.aws.amazon.com/sdk-for-ruby/v1/api/AWS/S3/S3Object.html
    # The bucket is private, ie all the public access is blocked
    # key = "uploads/5f31/1697038252270.jpg"
    def s3_presigned_url(key)
      s3 = Aws::S3::Resource.new(region: ENV.fetch('AWS_REGION'),
                                 access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
                                 secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
                                )

      bucket_name = ENV.fetch('AWS_BUCKET_NAME')
      bucket = s3.bucket(bucket_name)
      object = bucket.object(key)
      object.presigned_url(:get, expires_in: 3600)
    end
  end
end
