module SpreeCmCommissioner
  class S3PresignedUrl
    include ActiveModel::Serialization
    attr_reader :s3_direct_post
    attr_accessor :id, :error_message

    delegate :url, to: :s3_direct_post
    delegate :fields, to: :s3_direct_post

    def host
      URI.parse(url).host
    end

    def initialize(bucket_name, object_key, uuid = nil)
      @id = uuid.presence || generate_secure_random

      if object_key.blank?
        @error_message = I18n.t('s3_signed_url.missing_file_name')
      else
        @s3_direct_post = presigned_post(bucket_name, object_key)
      end
    end

    private

    def presigned_post(bucket_name, object_key)
      Aws::S3::Resource.new
                       .bucket(bucket_name)
                       .presigned_post(
                         key: object_key,
                         success_action_status: '201'
                       )
    end

    def generate_secure_random
      SecureRandom.uuid
    end
  end
end
