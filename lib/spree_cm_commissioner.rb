require 'spree'
require 'spree_api_v1'
require 'spree_backend'
require 'spree_auth_devise'
require 'spree_multi_vendor'
require 'spree_extension'

require 'spree_cm_commissioner/engine'
require 'spree_cm_commissioner/version'
require 'spree_cm_commissioner/passenger_option'
require 'spree_cm_commissioner/payment_method_group'
require 'spree_cm_commissioner/calendar_event'
require 'spree_cm_commissioner/s3_url_generator'
require 'spree_cm_commissioner/jwt_token'
require 'spree_cm_commissioner/line_item_jwt_token'
require 'spree_cm_commissioner/order_jwt_token'
require 'spree_cm_commissioner/trip_result'
require 'spree_cm_commissioner/trip_seat_layout_result'

require 'activerecord_multi_tenant'
require 'google/cloud/recaptcha_enterprise'
require 'searchkick'
require 'twilio-ruby'
require 'elasticsearch'
require 'interactor'
require 'phonelib'
require 'jwt'
require 'noticed'
require 'aws-sdk-s3'
require 'telegram/bot'
require 'exception_notification'

require 'simple_calendar'
require 'activerecord_json_validator'
require 'googleauth'
require 'dry-validation'
require 'font-awesome-sass'
require 'rqrcode'
require 'premailer/rails'
require 'cm_app_logger'
require 'counter_culture'

require 'byebug' if Rails.env.development? || Rails.env.test?

# TODO: remove disabling rubocop
module SpreeCmCommissioner
  class << self
    attr_accessor :redis_pool

    def redis_pool # rubocop:disable Lint/DuplicateMethods
      @redis_pool ||= default_redis_pool
    end

    # Allows overriding the default Redis connection pool with a custom one
    attr_writer :redis_pool # rubocop:disable Lint/DuplicateMethods

    # Resets the Redis pool, useful for testing or reinitialization
    def reset_redis_pool
      @redis_pool = nil
    end

    private

    def default_redis_pool
      pool_size = ENV.fetch('REDIS_POOL_SIZE', '5').to_i
      timeout = ENV.fetch('REDIS_TIMEOUT', '5').to_i
      redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/12')

      ConnectionPool.new(size: pool_size, timeout: timeout) do
        Redis.new(url: redis_url, timeout: timeout)
      end
    end
  end

  # Provides a configuration block for customizing SpreeCmCommissioner settings
  def self.configure
    yield self
  end
end
