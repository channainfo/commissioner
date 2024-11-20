require 'aws-sdk-cloudfront'

# pattern: '/api/v2/storefront/homepage_sections*'
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/invalidation-access-logs.html

module SpreeCmCommissioner
  class InvalidateCacheRequest < BaseInteractor
    delegate :pattern, to: :context

    def call
      client = ::Aws::CloudFront::Client.new(
        region: ENV.fetch('AWS_REGION'),
        access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
        secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
        http_open_timeout: 15,
        http_read_timeout: 60
      )

      context.response = client.create_invalidation(
        distribution_id: ENV.fetch('ASSETS_SYNC_CF_DIST_ID'),
        invalidation_batch: {
          caller_reference: Time.now.to_i.to_s,
          paths: {
            quantity: 1,
            items: [pattern]
          }
        }
      )
    end
  end
end
