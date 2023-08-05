class S3SignedUrl
  include ActiveModel::Serialization

  attr_accessor :id, :error_message

  delegate :url, to: :s3_direct_post
  delegate :fields, to: :s3_direct_post

  def initialize(file_name)
    if file_name.blank?
      @error_message = I18n.t('s3_signed_url.missing_file_name')
    else
      @id = SecureRandom.uuid
      @s3_direct_post = Aws::S3::Resource.new
                                         .bucket(ENV.fetch('AWS_BUCKET_NAME', nil))
                                         .presigned_post(
                                           key: "uploads/#{@id}/#{file_name}",
                                           success_action_status: '201',
                                           acl: 'public-read'
                                         )
    end
  end

  def host
    URI.parse(url).host
  end

  private

  attr_reader :s3_direct_post
end
