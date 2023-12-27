module SpreeCmCommissioner
  class S3UrlGenerator
    # https://docs.aws.amazon.com/sdk-for-ruby/v1/api/AWS/S3/S3Object.html
    # The bucket is private, ie all the public access is blocked
    # key = "uploads/5f31/1697038252270.jpg"
    def self.s3_presigned_url(url)
      key = url.split('amazonaws.com/').last

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
