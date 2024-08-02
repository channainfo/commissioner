require 'aws-sdk-cloudfront'

module SpreeCmCommissioner
  module Media
    class Signer
      include Interactor

      def signer
        @signer ||= Aws::CloudFront::UrlSigner.new(
          key_pair_id: key_pair_id,
          private_key: private_key
        )
      end

      def url
        "#{distribution_domain}/#{s3_object_key}"
      end

      def distribution_domain
        ENV.fetch('AWS_CF_MEDIA_DOMAIN')
      end

      def expiration_time
        @expiration_time ||= expiration_in_second.seconds.from_now.to_i
      end

      # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-creating-signed-url-canned-policy.html
      def key_pair_id
        ENV.fetch('AWS_CF_PUBLIC_KEY_ID')
      end

      def private_key
        ENV.fetch('AWS_CF_PRIVATE_KEY')
      end
    end
  end
end
