module SpreeCmCommissioner
  module Media
    class SignedCookieGenerator < Signer
      include Interactor

      delegate :s3_object_key, :expiration_in_second, to: :context

      def call
        sign
      end

      def sign
        # Generate the signed URL
        result = signer.signed_cookie(url, policy: policy.to_json)
        context.result = result
      end

      # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-creating-signed-url-custom-policy.html#private-content-custom-policy-statement
      def policy
        {
          'Statement' => [
            {
              'Resource' => "#{distribution_domain}/#{object_path}/*",
              'Condition' => {
                'DateLessThan' => { 'AWS:EpochTime' => expiration_time }
              }
            }
          ]
        }
      end

      def signer
        @signer ||= Aws::CloudFront::CookieSigner.new(key_pair_id: key_pair_id, private_key: private_key)
      end

      def object_path
        File.dirname(s3_object_key)
      end
    end
  end
end
