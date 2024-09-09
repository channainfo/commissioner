module SpreeCmCommissioner
  class S3PresignedUrlBuilder
    attr_reader :options

    def self.call(options)
      new(options).call
    end

    # {:bucket_name?, (:object_key | :file_name)? }
    def initialize(options)
      @options = options
    end

    def call
      SpreeCmCommissioner::S3PresignedUrl.new(bucket_name, object_key, uuid)
    end

    private

    def object_key
      return options[:object_key] if options[:object_key].present?

      "uploads/#{uuid}/#{options[:file_name]}"
    end

    def bucket_name
      options[:bucket_name].presence || default_bucket_name
    end

    def default_bucket_name
      ENV.fetch('AWS_BUCKET_NAME')
    end

    def uuid
      @uuid ||= options[:uuid].presence || SecureRandom.uuid
    end
  end
end
